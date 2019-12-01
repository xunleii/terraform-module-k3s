locals {
  minion_default_flags = [
    "--server https://${var.master_node.ip}:6443",
    "--token ${random_password.k3s_cluster_secret.result}"
  ]
  minion_install_flags = join(" ", concat(var.additional_flags.minion, local.minion_default_flags))
}

resource null_resource k3s_minions {
  for_each = var.minion_nodes

  triggers = {
    master_init  = null_resource.k3s_master.id
    install_args = sha1(local.minion_install_flags)
    minion_ip    = each.value.ip
  }
  depends_on = [null_resource.k3s_master_installer]

  connection {
    type = lookup(each.value.connection, "type", "ssh")

    host     = lookup(each.value.connection, "host", each.value.ip)
    user     = lookup(each.value.connection, "user", null)
    password = lookup(each.value.connection, "password", null)
    port     = lookup(each.value.connection, "port", null)
    timeout  = lookup(each.value.connection, "timeout", null)

    script_path    = lookup(each.value.connection, "script_path", null)
    private_key    = lookup(each.value.connection, "private_key", null)
    certificate    = lookup(each.value.connection, "certificate", null)
    agent          = lookup(each.value.connection, "agent", null)
    agent_identity = lookup(each.value.connection, "agent_identity", null)
    host_key       = lookup(each.value.connection, "host_key", null)

    https    = lookup(each.value.connection, "https", null)
    insecure = lookup(each.value.connection, "insecure", null)
    use_ntlm = lookup(each.value.connection, "use_ntlm", null)
    cacert   = lookup(each.value.connection, "cacert", null)

    bastion_host        = lookup(each.value.connection, "bastion_host", null)
    bastion_host_key    = lookup(each.value.connection, "bastion_host_key", null)
    bastion_port        = lookup(each.value.connection, "bastion_port", null)
    bastion_user        = lookup(each.value.connection, "bastion_user", null)
    bastion_password    = lookup(each.value.connection, "bastion_password", null)
    bastion_private_key = lookup(each.value.connection, "bastion_private_key", null)
    bastion_certificate = lookup(each.value.connection, "bastion_certificate", null)
  }

  # Check if curl is installed
  provisioner remote-exec {
    inline = [
      "if ! command -V curl > /dev/null; then echo >&2 '[ERROR] curl must be installed to continue...'; exit 127; fi",
    ]
  }

  # Remove old k3s installation
  provisioner remote-exec {
    inline = [
      "if ! command -V k3s-agent-uninstall.sh > /dev/null; then exit; fi",
      "echo >&2 [WARN] K3S seems already installed on this node and will be uninstalled.",
      "k3s-agent-uninstall.sh",
    ]
  }
}

resource null_resource k3s_minions_installer {
  for_each = var.minion_nodes

  triggers = {
    master_install = null_resource.k3s_master_installer.id
    minion_init    = null_resource.k3s_minions[each.key].id
    version        = local.k3s_version
  }

  connection {
    type = lookup(each.value.connection, "type", "ssh")

    host     = lookup(each.value.connection, "host", each.value.ip)
    user     = lookup(each.value.connection, "user", null)
    password = lookup(each.value.connection, "password", null)
    port     = lookup(each.value.connection, "port", null)
    timeout  = lookup(each.value.connection, "timeout", null)

    script_path    = lookup(each.value.connection, "script_path", null)
    private_key    = lookup(each.value.connection, "private_key", null)
    certificate    = lookup(each.value.connection, "certificate", null)
    agent          = lookup(each.value.connection, "agent", null)
    agent_identity = lookup(each.value.connection, "agent_identity", null)
    host_key       = lookup(each.value.connection, "host_key", null)

    https    = lookup(each.value.connection, "https", null)
    insecure = lookup(each.value.connection, "insecure", null)
    use_ntlm = lookup(each.value.connection, "use_ntlm", null)
    cacert   = lookup(each.value.connection, "cacert", null)

    bastion_host        = lookup(each.value.connection, "bastion_host", null)
    bastion_host_key    = lookup(each.value.connection, "bastion_host_key", null)
    bastion_port        = lookup(each.value.connection, "bastion_port", null)
    bastion_user        = lookup(each.value.connection, "bastion_user", null)
    bastion_password    = lookup(each.value.connection, "bastion_password", null)
    bastion_private_key = lookup(each.value.connection, "bastion_private_key", null)
    bastion_certificate = lookup(each.value.connection, "bastion_certificate", null)
  }

  # Install K3S agent
  provisioner remote-exec {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${local.k3s_version} INSTALL_K3S_EXEC=agent sh -s - ${local.minion_install_flags} --node-ip ${each.value.ip} --node-name ${each.key}"
    ]
  }
}

resource null_resource k3s_minions_uninstaller {
  for_each = var.minion_nodes

  triggers = {
    minion_init = null_resource.k3s_minions[each.key].id
  }

  connection {
    type = lookup(var.master_node.connection, "type", "ssh")

    host     = lookup(var.master_node.connection, "host", var.master_node.ip)
    user     = lookup(var.master_node.connection, "user", null)
    password = lookup(var.master_node.connection, "password", null)
    port     = lookup(var.master_node.connection, "port", null)
    timeout  = lookup(var.master_node.connection, "timeout", null)

    script_path    = lookup(var.master_node.connection, "script_path", null)
    private_key    = lookup(var.master_node.connection, "private_key", null)
    certificate    = lookup(var.master_node.connection, "certificate", null)
    agent          = lookup(var.master_node.connection, "agent", null)
    agent_identity = lookup(var.master_node.connection, "agent_identity", null)
    host_key       = lookup(var.master_node.connection, "host_key", null)

    https    = lookup(var.master_node.connection, "https", null)
    insecure = lookup(var.master_node.connection, "insecure", null)
    use_ntlm = lookup(var.master_node.connection, "use_ntlm", null)
    cacert   = lookup(var.master_node.connection, "cacert", null)

    bastion_host        = lookup(var.master_node.connection, "bastion_host", null)
    bastion_host_key    = lookup(var.master_node.connection, "bastion_host_key", null)
    bastion_port        = lookup(var.master_node.connection, "bastion_port", null)
    bastion_user        = lookup(var.master_node.connection, "bastion_user", null)
    bastion_password    = lookup(var.master_node.connection, "bastion_password", null)
    bastion_private_key = lookup(var.master_node.connection, "bastion_private_key", null)
    bastion_certificate = lookup(var.master_node.connection, "bastion_certificate", null)
  }

  # Drain and delete the removed node
  provisioner remote-exec {
    when = destroy
    inline = [
      "kubectl drain ${each.key} --force --delete-local-data --ignore-daemonsets --timeout ${var.drain_timeout}",
      "kubectl delete node ${each.key}",
      "sed -i \"/${each.key}/d\" /var/lib/rancher/k3s/server/cred/node-passwd",
    ]
  }
}
