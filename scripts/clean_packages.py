import requests


GITHUB_TOKEN = ""

BASE_URL = "https://api.github.com"

headers = {
    "Authorization": f"token {GITHUB_TOKEN}",
    "Accept": "application/vnd.github.v3+json",
}


def get_packages():
    url = f"{BASE_URL}/users/TjanL/packages?package_type=container"
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Failed to fetch packages: {response.status_code} {response.text}")
        return []


def delete_package(package):
    package_name = package["name"]
    package_type = package["package_type"]
    url = f"{BASE_URL}/user/packages/{package_type}/{package_name}"
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f"Successfully deleted package: {package_name}")
    else:
        print(
            f"Failed to delete package {package_name}: {response.status_code} {response.text}"
        )


packages = get_packages()
for package in packages:
    delete_package(package)
