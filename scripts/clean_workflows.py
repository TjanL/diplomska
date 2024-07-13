import requests

GITHUB_TOKEN = ""

repositories = [
    "monorepo-feature-docker",
    "monorepo-trunk-docker",
    "per-component-app-feature-docker",
    "per-component-app-trunk-docker",
    "per-component-server-feature-docker",
    "per-component-server-trunk-docker",
    "monorepo-feature-js",
    "monorepo-trunk-js",
    "per-component-app-feature-js",
    "per-component-app-trunk-js",
    "per-component-server-feature-js",
    "per-component-server-trunk-js",
    "monorepo-feature-composite",
    "monorepo-trunk-composite",
    "per-component-app-feature-composite",
    "per-component-app-trunk-composite",
    "per-component-server-feature-composite",
    "per-component-server-trunk-composite",
]

BASE_URL = "https://api.github.com"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json",
}


def fetch_workflow_runs(repo_name):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/actions/runs"
    response = requests.get(url, headers=headers)
    runs = response.json().get("workflow_runs", [])
    return runs


def delete_workflow_run(repo_name, run_id):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/actions/runs/{run_id}"
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f"Deleted workflow run {run_id} from {repo_name}")
    else:
        print(
            f"Failed to delete workflow run {run_id} from {repo_name}: {response.status_code}"
        )


def fetch_pull_requests(repo_name):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/pulls"
    response = requests.get(url, headers=headers)
    prs = response.json()
    return prs


def close_pull_request(repo_name, pr_number):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/pulls/{pr_number}"
    data = {"state": "closed"}
    response = requests.patch(url, headers=headers, json=data)
    if response.status_code == 200:
        print(f"Closed pull request {pr_number} from {repo_name}")
        return True
    else:
        print(
            f"Failed to close pull request {pr_number} from {repo_name}: {response.status_code}"
        )
        return False


def delete_branch(repo_name, branch_name):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/git/refs/heads/{branch_name}"
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f"Deleted branch {branch_name} from {repo_name}")
    else:
        print(
            f"Failed to delete branch {branch_name} from {repo_name}: {response.status_code}"
        )


for repo in repositories:
    workflow_runs = fetch_workflow_runs(repo)
    for run in workflow_runs:
        delete_workflow_run(repo, run["id"])

    pull_requests = fetch_pull_requests(repo)
    for pr in pull_requests:
        if close_pull_request(repo, pr["number"]):
            branch_name = pr["head"]["ref"]
            delete_branch(repo, branch_name)

print("All workflow runs, pull requests, and associated branches have been processed.")
