resource "vagrant_vm" "k3s_nodes" {
  get_ports = true
}

output "debug_sshconfig" {
  value = vagrant_vm.k3s_nodes.ssh_config
}

output "debug_ports" {
  value = vagrant_vm.k3s_nodes.ports
}
