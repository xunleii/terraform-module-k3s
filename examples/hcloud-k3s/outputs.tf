output "summary" {
  value = module.k3s.summary
}

output "ssh_private_key" {
  description = "Generated SSH private key."
  value       = tls_private_key.ed25519-provisioning.private_key_openssh
  sensitive   = true
}