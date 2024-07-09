const core = require('@actions/core');
const exec = require('@actions/exec');
const fs = require('fs');
const path = require('path');

async function run() {
    try {
        // Get inputs
        const sshKey = core.getInput('ssh_key', { required: true });
        const remoteDockerHost = core.getInput('remote_docker_host', { required: true });
        const dockerImage = core.getInput('docker_image', { required: true });
        const containerName = core.getInput('container_name', { required: true });
        const envVars = core.getInput('env_vars');
        const ports = core.getInput('ports');
        const volumes = core.getInput('volumes');
        const network = core.getInput('network');

        // Create SSH key file
        const sshDir = path.join(process.env.HOME, '.ssh');
        if (!fs.existsSync(sshDir)) {
            fs.mkdirSync(sshDir, { recursive: true });
        }
        const sshKeyPath = path.join(sshDir, 'id_rsa');
        fs.writeFileSync(sshKeyPath, sshKey);
        fs.chmodSync(sshKeyPath, '600');

        await exec.exec(`eval "$(ssh-agent -s)"`);
        await exec.exec(`ssh-add ${sshKeyPath}`);
        await exec.exec(`echo "StrictHostKeyChecking no" >> $(find /etc -iname ssh_config)`);

        // Create Docker context and use it
        await exec.exec(`docker context create remote-docker --docker "host=ssh://${remoteDockerHost}"`);
        await exec.exec(`docker context use remote-docker`);

        // Prepare environment variable options
        let envVarsOption = '';
        if (envVars) {
            envVars.split(',').forEach(varPair => {
                envVarsOption += `-e ${varPair} `;
            });
        }

        // Prepare port options
        let portOptions = '';
        if (ports) {
            ports.split(',').forEach(portPair => {
                portOptions += `-p ${portPair} `;
            });
        }

        // Prepare volume options
        let volumeOptions = '';
        if (volumes) {
            volumes.split(',').forEach(volumePair => {
                volumeOptions += `-v ${volumePair} `;
            });
        }

        // Prepare network options and create network if it doesn't exist
        let networkOption = '';
        if (network) {
            try {
                await exec.exec(`docker network inspect ${network}`);
            } catch (error) {
                await exec.exec(`docker network create ${network}`);
            }
            networkOption = `--network ${network}`;
        }

        // Deploy the Docker image
        await exec.exec(`docker pull ${dockerImage}`);
        await exec.exec(`docker stop ${containerName} || true`);
        await exec.exec(`docker rm ${containerName} || true`);
        await exec.exec(`docker run -d --name ${containerName} ${envVarsOption} ${portOption} ${volumeOptions} ${networkOption} ${dockerImage}`);

    } catch (error) {
        core.setFailed(error.message);
    }
}

run();
