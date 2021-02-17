// Generate the k3s token used by all nodes to join the cluster
resource "random_password" "k3s_cluster_secret" {
  length  = 48
  special = false
}

locals {
  managed_annotation_enabled = contains(var.managed_fields, "annotation")
  managed_label_enabled      = contains(var.managed_fields, "label")
  managed_taint_enabled      = contains(var.managed_fields, "taint")
}

// null_resource used as dependency agregation.
resource "null_resource" "kubernetes_ready" {
  depends_on = [
    null_resource.servers_install, null_resource.servers_drain, null_resource.servers_annotation, null_resource.servers_label, null_resource.servers_taint,
    null_resource.agents_install, null_resource.agents_drain, null_resource.agents_annotation, null_resource.agents_label, null_resource.agents_taint,
  ]
}
