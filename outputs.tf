output "summary" {
  value = {
    servers : [
      for nk, nv in var.servers :
      {
        name        = data.null_data_source.servers_metadata[nk].outputs.name
        annotations = try(nv.annotations, [])
        labels      = try(nv.labels, [])
        taints      = try(nv.taints, [])
      }
    ]
    agents : [
      for nk, nv in var.agents :
      {
        name        = data.null_data_source.agents_metadata[nk].outputs.name
        annotations = try(nv.annotations, [])
        labels      = try(nv.labels, [])
        taints      = try(nv.taints, [])
      }
    ]
  }
}
