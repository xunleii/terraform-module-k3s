variable k3s_version {
  description = "Specify the k3s version."
  type        = string
  default     = "latest"
}

variable cluster_name {
  description = "K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type        = string
  default     = "cluster.local"
}

variable cluster_cidr {
  description = "K3s network CIDRs (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type = object({
    pods     = string
    services = string
  })
  default = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
}

variable additional_flags {
  description = "Add additional flags during the k3s installation (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type = object({
    server = list(string)
    agent  = list(string)
  })
  default = {
    server = []
    agent  = []
  }
}

variable drain_timeout {
  description = "The length of time to wait before giving up the node draining. Infinite by default."
  type        = string
  default     = "0s"
}

variable server_node {
  description = "K3s server node definition."
  type = object({
    name       = string
    ip         = string
    connection = map(any)
  })
}

variable agent_nodes {
  description = "K3s agent nodes definitions. The key is used as node name during the k3s installation."
  type = map(object({
    ip         = string
    connection = map(any)
  }))
  default = {}
}
