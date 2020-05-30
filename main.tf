terraform {
  required_version = "~> 0.12"
  experiments      = [variable_validation]
  required_providers {
    http     = "~> 1.1"
    local    = "~> 1.4"
    null     = "~> 2.1"
    random   = "~> 2.2"
    template = "~> 2.1"
  }
}

resource "random_password" "k3s_cluster_secret" {
  length  = 48
  special = false
}

locals {
  managed_annotation_enabled = contains(var.managed_fields, "annotation")
  managed_label_enabled      = contains(var.managed_fields, "label")
  managed_taint_enabled      = contains(var.managed_fields, "taint")
}