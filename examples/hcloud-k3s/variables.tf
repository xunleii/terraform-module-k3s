variable ssh_key {
  description = "SSH public Key content needed to provision the instances."
  type        = string
}

variable agents_num {
  description = "Number of agent nodes."
  default     = 3
}