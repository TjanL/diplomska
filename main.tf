terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

locals {
  workflows = [
    "monorepo-feature-docker",
    "monorepo-trunk-docker",
    "per-component-app-feature-docker",
    "per-component-app-trunk-docker",
    "per-component-server-feature-dockerr",
    "per-component-server-trunk-docker",
  ]
}

variable "ts_oauth_client_id" {}
variable "ts_oauth_secret" {}
variable "ssh_private_key" {}

resource "github_repository" "repositories" {
  for_each = toset(local.workflows)

  name       = each.value
  visibility = "public"
  auto_init  = true
}

resource "github_actions_secret" "tailscale_client_id" {
  for_each = github_repository.repositories

  repository      = each.value.name
  secret_name     = "TS_OAUTH_CLIENT_ID"
  plaintext_value = var.ts_oauth_client_id
}

resource "github_actions_secret" "tailscale_oauth" {
  for_each = github_repository.repositories

  repository      = each.value.name
  secret_name     = "TS_OAUTH_SECRET"
  plaintext_value = var.ts_oauth_secret
}

resource "github_actions_secret" "ssh_private_key" {
  for_each = github_repository.repositories

  repository      = each.value.name
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = var.ssh_private_key
}

resource "null_resource" "clone" {
  for_each = github_repository.repositories

  provisioner "local-exec" {
    command = "gh repo clone ${each.value.name} ${path.module}/workflows/${each.value.name}"
  }
}
