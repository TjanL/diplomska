const core = require('@actions/core');
const exec = require('@actions/exec');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

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
        fs.writeFileSync(sshKeyPath, sshKey + '\n');
        fs.chmodSync(sshKeyPath, '600');

        // Start ssh-agent and add the SSH key
        const sshAgentOutput = execSync('ssh-agent').toString();
        const sshAgentRegex = /SSH_AUTH_SOCK=([^;]+); export SSH_AUTH_SOCK;\nSSH_AGENT_PID=([^;]+); export SSH_AGENT_PID;/;
        const match = sshAgentRegex.exec(sshAgentOutput);
        if (match) {
            process.env.SSH_AUTH_SOCK = match[1];
            process.env.SSH_AGENT_PID = match[2];
        } else {
            throw new Error('Failed to start ssh-agent');
        }
        execSync(`ssh-add ${sshKeyPath}`);

        // Create SSH config file for StrictHostKeyChecking
        const sshConfigPath = path.join(sshDir, 'config');
        const host = remoteDockerHost.split('@')[1];
        const sshConfigContent = `
Host ${host}
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
        `;
        fs.writeFileSync(sshConfigPath, sshConfigContent);

        // Create Docker context and use it
        await exec.exec(`docker context create remote-docker --docker "host=ssh://${remoteDockerHost}"`, [], { ignoreReturnCode: true });
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
            await exec.exec(`docker network create ${network}`, [], { ignoreReturnCode: true });
            networkOption = `--network ${network}`;
        }

        // Deploy the Docker image
        await exec.exec(`docker pull ${dockerImage}`);
        await exec.exec(`docker stop ${containerName}`, [], { ignoreReturnCode: true });
        await exec.exec(`docker rm ${containerName}`, [], { ignoreReturnCode: true });
        await exec.exec(`docker run -d --name ${containerName} ${envVarsOption} ${portOptions} ${volumeOptions} ${networkOption} ${dockerImage}`);

    } catch (error) {
        core.setFailed(error.message);
    }
}

run();
