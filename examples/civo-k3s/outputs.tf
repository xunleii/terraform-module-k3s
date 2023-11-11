output "summary" {
  value = module.k3s.summary
}

output "kubeconfig" {
  value     = module.k3s.kube_config
  sensitive = true
}
