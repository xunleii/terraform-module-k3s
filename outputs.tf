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
