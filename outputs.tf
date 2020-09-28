output "kubernetes" {
  value = {
    cluster_ca_certificate = local.cluster_ca_certificate
    client_certificate     = local.cluster_ca_certificate
    client_key             = local.client_key
    api_endpoint           = "https://${local.root_server_connection.host}:6443"
    password               = null
    username               = null
  }
  sensitive = true
}

output kube_config {
  value = var.generate_ca_certificates == false ? null : yamlencode({
    apiVersion = "v1"
    clusters = [{
      cluster = {
        certificate-authority-data = base64encode(local.cluster_ca_certificate)
        server                     = "https://${local.root_server_connection.host}:6443"
      }
      name = var.name
    }]
    contexts = [{
      context = {
        cluster = var.name
        user : "master-user"
      }
      name = var.name
    }]
    current-context = var.name
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

// Return a "summary" of the current k3s cluster (version & nodes)
output "summary" {
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
