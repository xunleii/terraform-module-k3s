output "kubernetes" {
  description = "Authentication credentials of Kubernetes (full administrator)."
  value = {
    cluster_ca_certificate = local.cluster_ca_certificate
    client_certificate     = local.client_certificate
    client_key             = local.client_key
    api_endpoint           = "https://${local.root_server_connection.host}:6443"
    password               = null
    username               = null
  }
  sensitive = true
}

output "kube_config" {
  description = "Genereated kubeconfig."
  value = var.generate_ca_certificates == false ? null : yamlencode({
    apiVersion = "v1"
    clusters = [{
      cluster = {
        certificate-authority-data = base64encode(local.cluster_ca_certificate)
        server                     = "https://${local.root_server_connection.host}:6443"
      }
      name = var.cluster_domain
    }]
    contexts = [{
      context = {
        cluster = var.cluster_domain
        user : "master-user"
      }
      name = var.cluster_domain
    }]
    current-context = var.cluster_domain
    kind            = "Config"
    preferences     = {}
    users = [{
      user = {
        client-certificate-data : base64encode(local.client_certificate)
        client-key-data : base64encode(local.client_key)
      }
      name : "master-user"
    }]
  })
  sensitive = true
}

output "summary" {
  description = "Current state of k3s (version & nodes)."
  value = {
    version : local.k3s_version
    servers : [
      for key, server in var.servers :
      {
        name        = local.servers_metadata[key].name
        annotations = try(server.annotations, [])
        labels      = try(server.labels, [])
        taints      = try(server.taints, [])
      }
    ]
    agents : [
      for key, agent in var.agents :
      {
        name        = local.agents_metadata[key].name
        annotations = try(agent.annotations, [])
        labels      = try(agent.labels, [])
        taints      = try(agent.taints, [])
      }
    ]
  }
}

output "kubernetes_ready" {
  description = "Dependency endpoint to synchronize k3s installation and provisioning."
  value       = null_resource.kubernetes_ready
}

output "kubernetes_cluster_secret" {
  description = "Secret token used to join nodes to the cluster"
  value       = random_password.k3s_cluster_secret.result
  sensitive   = true
}
