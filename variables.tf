variable "k3s_version" {
  description = "Specify the k3s version."
  type        = string
  default     = "latest"
}

variable "cluster_name" {
  description = "K3s cluster domain (see --cluster-domain)."
  type        = string
  default     = "cluster.local"
}

variable "cluster_cidr" {
  description = "Network CIDR to use for pod IPs (see --cluster-cidr)."
  type        = string
  default     = "10.42.0.0/16"
}

variable "cluster_service_cidr" {
  description = "Network CIDR to use for services IPs (see --service-cidr)."
  type        = string
  default     = "10.43.0.0/16"
}

variable "additional_tls_san" {
  description = "Add additional hostname or IP as a Subject Alternative Name in the TLS cert (see --tls-san)."
  type        = list(string)
  default     = []
}

variable "master_node" {
  description = "Configuration of the K3S master node."
  type = object({
    ip         = string
    connection = map(any)
  })
}

variable "minion_nodes" {
  description = "List of minion configuration nodes."
  type = map(object({
    ip         = string
    connection = map(any)
  }))
  default = {}
}
