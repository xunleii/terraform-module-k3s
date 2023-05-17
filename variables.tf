variable "depends_on_" {
  description = "Resource dependency of this module."
  default     = null
}

variable "k3s_version" {
  description = "Specify the k3s version. You can choose from the following release channels or pin the version directly"
  type        = string
  default     = "latest"
}

variable "k3s_install_env_vars" {
  description = "map of enviroment variables that are passed to the k3s installation script (see https://docs.k3s.io/reference/env-variables)"
  type        = map(string)
  default     = {}

  validation {
    condition     = !can(var.k3s_install_env_vars["INSTALL_K3S_VERSION"])
    error_message = "Environment variable \"INSTALL_K3S_VERSION\" needs to be set via variable k3s_version"
  }
}

variable "name" {
  description = "K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). This input is deprecated and will be remove in the next major release. Use `cluster_domain` instead."
  type        = string
  default     = "!!!DEPRECATED!!!"

  validation {
    condition     = var.name == "!!!DEPRECATED!!!"
    error_message = "Variable `name` is deprecated, use `cluster_domain` instead. It will be removed at the next major release."
  }
}

variable "cluster_domain" {
  description = "K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type        = string
  default     = "cluster.local"
}

variable "generate_ca_certificates" {
  description = "If true, this module will generate the CA certificates (see https://github.com/rancher/k3s/issues/1868#issuecomment-639690634). Otherwise rancher will generate it. This is required to generate kubeconfig"
  type        = bool
  default     = true
}

variable "kubernetes_certificates" {
  description = "A list of maps of cerificate-name.[crt/key] : cerficate-value to copied to /var/lib/rancher/k3s/server/tls, if this option is used generate_ca_certificates will be treat as false"
  type = list(
    object({
      file_name    = string,
      file_content = string
    })
  )
  default = []
}

variable "cidr" {
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

variable "drain_timeout" {
  description = "The length of time to wait before giving up the node draining. Infinite by default."
  type        = string
  default     = "0s"
}

variable "global_flags" {
  description = "Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/)."
  type        = list(string)
  default     = []
}

variable "servers" {
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
    condition     = !can(values(var.servers)[*].connection) || !contains([for v in var.servers : can(tomap(v.connection))], false)
    error_message = "Field servers.<name>.connection must be a valid Terraform connection."
  }
  validation {
    condition     = !can(values(var.servers)[*].flags) || !contains([for v in var.servers : can(tolist(v.flags))], false)
    error_message = "Field servers.<name>.flags must be a list of string (see: https://docs.k3s.io/cli/server)."
  }
  validation {
    condition     = !can(values(var.servers)[*].annotations) || !contains([for v in var.servers : can(tomap(v.annotations))], false)
    error_message = "Field servers.<name>.annotations must be a map of string."
  }
  validation {
    condition     = !can(values(var.servers)[*].labels) || !contains([for v in var.servers : can(tomap(v.labels))], false)
    error_message = "Field servers.<name>.labels must be a map of string."
  }
  validation {
    condition     = !can(values(var.servers)[*].taints) || !contains([for v in var.servers : can(tomap(v.taints))], false)
    error_message = "Field servers.<name>.taints must be a map of string."
  }
}

variable "agents" {
  description = "K3s agent nodes definitions. The key is used as node name if no name is provided."
  type        = map(any)
  default     = {}

  validation {
    condition     = can(values(var.agents)[*].ip)
    error_message = "Field agents.<name>.ip is required."
  }
  validation {
    condition     = !can(values(var.agents)[*].connection) || !contains([for v in var.agents : can(tomap(v.connection))], false)
    error_message = "Field agents.<name>.connection must be a valid Terraform connection."
  }
  validation {
    condition     = !can(values(var.agents)[*].flags) || !contains([for v in var.agents : can(tolist(v.flags))], false)
    error_message = "Field agents.<name>.flags must be a list of string (see: https://docs.k3s.io/cli/agent)."
  }
  validation {
    condition     = !can(values(var.agents)[*].annotations) || !contains([for v in var.agents : can(tomap(v.annotations))], false)
    error_message = "Field agents.<name>.annotations must be a map of string."
  }
  validation {
    condition     = !can(values(var.agents)[*].labels) || !contains([for v in var.agents : can(tomap(v.labels))], false)
    error_message = "Field agents.<name>.labels must be a map of string."
  }
  validation {
    condition     = !can(values(var.agents)[*].taints) || !contains([for v in var.agents : can(tomap(v.taints))], false)
    error_message = "Field agents.<name>.taints must be a map of string."
  }
}

variable "managed_fields" {
  description = "List of fields which must be managed by this module (can be annotation, label and/or taint)."
  type        = list(string)
  default     = ["annotation", "label", "taint"]
}

variable "separator" {
  description = "Separator used to separates node name and field name (used to manage annotations, labels and taints)."
  default     = "|"
}

variable "use_sudo" {
  description = "Whether or not to use kubectl with sudo during cluster setup."
  default     = false
  type        = bool
}
