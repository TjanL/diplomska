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
}

variable "ts_oauth_client_id" {
  type      = string
  sensitive = true
}
variable "ts_oauth_secret" {
  type      = string
  sensitive = true
}
variable "ts_node_ip" {
  type = string
}
variable "ssh_private_key" {
  type      = string
  sensitive = true
}
variable "github_registry_pat" {
  type      = string
  sensitive = true
}

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

resource "github_actions_secret" "tailscale_node_ip" {
  for_each = github_repository.repositories

  repository      = each.value.name
  secret_name     = "TS_NODE_IP"
  plaintext_value = var.ts_node_ip
}

resource "github_actions_secret" "ssh_private_key" {
  for_each = github_repository.repositories

  repository      = each.value.name
  secret_name     = "SSH_PRIVATE_KEY"
  plaintext_value = file(var.ssh_private_key)
}

resource "github_actions_secret" "github_registry_pat" {
  for_each = github_repository.repositories

  repository      = each.value.name
  secret_name     = "GHRC_TOKEN"
  plaintext_value = var.github_registry_pat
}

resource "null_resource" "clone" {
  for_each = github_repository.repositories

  provisioner "local-exec" {
    command = "gh repo clone ${each.value.name} ${path.module}/workflows/${each.value.name}"
  }
}
