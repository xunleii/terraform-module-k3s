output "summary" {
  value = module.k3s.summary
}

output "bootstrap_sa" {
  description = "Bootstrap ServiceAccount. Can be used by Terraform to provision this cluster."
  value       = data.kubernetes_secret.sa_credentials.data
  sensitive   = true
}
