variable "ssh_key" {
  description = "SSH public Key content needed to provision the instances."
  type        = "string"
}

variable "minions_num" {
  description = "Number of minion nodes."
  default     = 3
}