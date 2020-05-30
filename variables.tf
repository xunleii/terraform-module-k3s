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

variable servers {
  description = "K3s server nodes definition. The key is used as node name if no name is provided."
  type        = map(any)

  validation {
    condition     = length(var.servers) > 0
    error_message = "At least one server node must be provided."
  }
  validation {
    condition     = length(var.servers) % 2 == 1
    error_message = "Servers must have an odd number of nodes."
  }
  validation {
    condition     = can(values(var.servers)[*].ip)
    error_message = "Field servers.<name>.ip is required."
  }
  validation {
    condition     = ! can(values(var.servers)[*].connection) || ! contains([for v in var.servers : can(tomap(v.connection))], false)
    error_message = "Field servers.<name>.connection must be a valid Terraform connection."
  }
  validation {
    condition     = ! can(values(var.servers)[*].flags) || ! contains([for v in var.servers : can(tolist(v.flags))], false)
    error_message = "Field servers.<name>.flags must be a list of string."
  }
  validation {
    condition     = ! can(values(var.servers)[*].annotations) || ! contains([for v in var.servers : can(tomap(v.annotations))], false)
    error_message = "Field servers.<name>.annotations must be a list of string."
  }
  validation {
    condition     = ! can(values(var.servers)[*].annotations) || ! contains([for v in var.servers : can(tomap(v.annotations))], false)
    error_message = "Field servers.<name>.annotations must be a map of string."
  }
  validation {
    condition     = ! can(values(var.servers)[*].labels) || ! contains([for v in var.servers : can(tomap(v.labels))], false)
    error_message = "Field servers.<name>.labels must be a map of string."
  }
  validation {
    condition     = ! can(values(var.servers)[*].taints) || ! contains([for v in var.servers : can(tomap(v.taints))], false)
    error_message = "Field servers.<name>.taints must be a map of string."
  }
}

variable agents {
  description = "K3s agent nodes definitions. The key is used as node name if no name is provided."
  type        = map(any)
  default     = {}
}

variable managed_fields {
  description = "List of fields which must be managed by this module (can be annotation, label and/or taint)."
  type        = list(string)
  default     = ["annotation", "label", "taint"]
}

variable separator {
  description = "Separator used to separates node name and field name (used to manage annotations, labels and taints)."
  default     = "|"
}