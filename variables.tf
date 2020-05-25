variable k3s_version {
  description = "Specify the k3s version."
  type        = string
  default     = "latest"
}

variable name {
  description = "K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type        = string
  default     = "cluster.local"
}

variable cidr {
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

variable drain_timeout {
  description = "The length of time to wait before giving up the node draining. Infinite by default."
  type        = string
  default     = "0s"
}

variable global_flags {
  description = "Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type = list(string)
  default = []
}

variable server {
  description = "K3s server node definition."
  type = any
}

variable agents {
  description = "K3s agent nodes definitions. The key is used as node name if no name is provided."
  type = map(any)
  default = {}
}
