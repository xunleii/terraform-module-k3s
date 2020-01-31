locals {
  agent_default_flags = [
    "--server https://${var.server_node.ip}:6443",
    "--token ${random_password.k3s_cluster_secret.result}"
  ]
  agent_install_flags = join(" ", concat(var.additional_flags.agent, local.agent_default_flags))
}

resource null_resource k3s_agents {
  for_each = var.agent_nodes

  triggers = {
    server_init  = null_resource.k3s_server.id
    install_args = sha1(local.agent_install_flags)
    agent_ip     = each.value.ip
  }
  depends_on = [null_resource.k3s_server_installer]

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

  # Remove old k3s installation
  provisioner remote-exec {
    inline = [
      "if ! command -V k3s-agent-uninstall.sh > /dev/null; then exit; fi",
      "echo >&2 [WARN] K3s seems already installed on this node and will be uninstalled.",
      "k3s-agent-uninstall.sh",
    ]
  }
}

resource null_resource k3s_agents_installer {
  for_each = var.agent_nodes

  triggers = {
    server_install = null_resource.k3s_server_installer.id
    agent_init     = null_resource.k3s_agents[each.key].id
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

  # Upload k3s file
  provisioner file {
    content     = data.http.k3s_installer.body
    destination = "/tmp/k3s-installer"
  }

  # Install K3S agent
  provisioner remote-exec {
    inline = [
      <<EOT
INSTALL_K3S_VERSION=${local.k3s_version} INSTALL_K3S_EXEC=agent sh /tmp/k3s-installer ${local.agent_install_flags} \
${join(" ", [for label, value in each.value.labels : "--node-label '${label}=${value}'" if value != null])} \
${join(" ", [for key, taint in each.value.taints : "--node-taint '${key}=${taint}'" if taint != null])} \
--node-ip ${each.value.ip} --node-name ${each.value.name}
      EOT
    ]
  }
}

resource null_resource k3s_agent_cache {
  for_each = var.agent_nodes

  triggers = {
    node_name = each.value.name
  }
}

resource null_resource k3s_agents_uninstaller {
  for_each = var.agent_nodes

  triggers = {
    agent_init = null_resource.k3s_agents[each.key].id
    node_cache = null_resource.k3s_agent_cache[each.key].id
  }

  connection {
    type = lookup(var.server_node.connection, "type", "ssh")

    host     = lookup(var.server_node.connection, "host", var.server_node.ip)
    user     = lookup(var.server_node.connection, "user", null)
    password = lookup(var.server_node.connection, "password", null)
    port     = lookup(var.server_node.connection, "port", null)
    timeout  = lookup(var.server_node.connection, "timeout", null)

    script_path    = lookup(var.server_node.connection, "script_path", null)
    private_key    = lookup(var.server_node.connection, "private_key", null)
    certificate    = lookup(var.server_node.connection, "certificate", null)
    agent          = lookup(var.server_node.connection, "agent", null)
    agent_identity = lookup(var.server_node.connection, "agent_identity", null)
    host_key       = lookup(var.server_node.connection, "host_key", null)

    https    = lookup(var.server_node.connection, "https", null)
    insecure = lookup(var.server_node.connection, "insecure", null)
    use_ntlm = lookup(var.server_node.connection, "use_ntlm", null)
    cacert   = lookup(var.server_node.connection, "cacert", null)

    bastion_host        = lookup(var.server_node.connection, "bastion_host", null)
    bastion_host_key    = lookup(var.server_node.connection, "bastion_host_key", null)
    bastion_port        = lookup(var.server_node.connection, "bastion_port", null)
    bastion_user        = lookup(var.server_node.connection, "bastion_user", null)
    bastion_password    = lookup(var.server_node.connection, "bastion_password", null)
    bastion_private_key = lookup(var.server_node.connection, "bastion_private_key", null)
    bastion_certificate = lookup(var.server_node.connection, "bastion_certificate", null)
  }

  # Drain and delete the removed node
  provisioner remote-exec {
    when = destroy
    inline = [
      "kubectl drain ${null_resource.k3s_agent_cache[each.key].triggers.node_name} --force --delete-local-data --ignore-daemonsets --timeout ${var.drain_timeout}",
      "kubectl delete node ${null_resource.k3s_agent_cache[each.key].triggers.node_name}",
      "sed -i \"/${null_resource.k3s_agent_cache[each.key].triggers.node_name}/d\" /var/lib/rancher/k3s/server/cred/node-passwd",
    ]
  }
}
