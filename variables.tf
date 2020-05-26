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
  type        = list(string)
  default     = []
}

variable server {
  description = "K3s server node definition."
  type        = any

  validation {
    condition     = can(var.server.name)
    error_message = "Field server.name is required."
  }
  validation {
    condition     = can(var.server.ip)
    error_message = "Field server.ip is required and must be an IP."
  }
  validation {
    condition     = ! can(var.server.connection) || can(tomap(var.server.connection))
    error_message = "Field server.connection must be a valid Terraform connection."
  }
  validation {
    condition     = ! can(var.server.flags) || can(tolist(var.server.flags))
    error_message = "Field server.flags must be a list of string."
  }
  validation {
    condition     = ! can(var.server.annotations) || can(tomap(var.server.annotations))
    error_message = "Field server.annotations must be a map of string."
  }
  validation {
    condition     = ! can(var.server.labels) || can(tomap(var.server.labels))
    error_message = "Field server.labels must be a map of string."
  }
  validation {
    condition     = ! can(var.server.taints) || can(tomap(var.server.taints))
    error_message = "Field server.taints must be a map of string."
  }
}

variable agents {
  description = "K3s agent nodes definitions. The key is used as node name if no name is provided."
  type        = map(any)
  default     = {}
}
