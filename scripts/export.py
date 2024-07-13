import requests
import json

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


def get_run_count(repo_name):
    if "monorepo-feature" in repo_name:
        return 4
    elif "per-component" in repo_name and "feature" in repo_name:
        return 2
    elif "monorepo-trunk" in repo_name:
        return 2
    elif "per-component" in repo_name and "trunk" in repo_name:
        return 1
    return 1


def fetch_jobs_for_run(repo_name, run_id):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/actions/runs/{run_id}/jobs"
    response = requests.get(url, headers=headers)
    jobs = response.json().get("jobs", [])

    job_info = []
    for job in jobs:
        steps = [
            {
                "name": step["name"],
                "status": step["status"],
                "conclusion": step["conclusion"],
                "number": step["number"],
                "started_at": step["started_at"],
                "completed_at": step["completed_at"],
            }
            for step in job.get("steps", [])
        ]

        job_info.append(
            {
                "id": job["id"],
                "name": job["name"],
                "status": job["status"],
                "conclusion": job["conclusion"],
                "started_at": job["started_at"],
                "completed_at": job["completed_at"],
                "steps": steps,
            }
        )

    return job_info


def fetch_workflow_runs(repo_name, run_count):
    url = f"{BASE_URL}/repos/TjanL/{repo_name}/actions/runs"
    response = requests.get(url, headers=headers)
    runs = response.json().get("workflow_runs", [])[:run_count]

    run_info = []
    for run in runs:
        jobs = fetch_jobs_for_run(repo_name, run["id"])
        run_info.append(
            {
                "id": run["id"],
                "name": run["name"],
                "status": run["status"],
                "conclusion": run["conclusion"],
                "created_at": run["created_at"],
                "updated_at": run["updated_at"],
                "run_started_at": run["run_started_at"],
                "jobs": jobs,
            }
        )

    return run_info


all_repo_info = {}

for repo in repositories:
    run_count = get_run_count(repo)
    workflow_runs = fetch_workflow_runs(repo, run_count)
    all_repo_info[repo] = workflow_runs

    total_runs = len(workflow_runs)
    successful_runs = sum(1 for run in workflow_runs if run["conclusion"] == "success")
    failed_runs = sum(1 for run in workflow_runs if run["conclusion"] == "failure")

    print(f"Repository: {repo}")
    print(f"Total workflow runs: {total_runs}")
    print(f"Successful runs: {successful_runs}")
    print(f"Failed runs: {failed_runs}")
    print("-" * 40)

with open("exports/workflow_run_info_with_jobs_and_steps.json", "w") as f:
    json.dump(all_repo_info, f, indent=4)

print(
    "Workflow run information with job and step details saved to exports/workflow_run_info_with_jobs_and_steps.json"
)
