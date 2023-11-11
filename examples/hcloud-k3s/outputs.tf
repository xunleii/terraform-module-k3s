output "summary" {
  value = module.k3s.summary
}

output "kubeconfig" {
  value     = module.k3s.kube_config
  sensitive = true
}

output "ssh_private_key" {
  description = "Generated SSH private key."
  value       = tls_private_key.ed25519_provisioning.private_key_openssh
  sensitive   = true
}
