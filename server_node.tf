locals {
  server_default_flags = [
    "--node-ip ${var.server_node.ip}",
    "--node-name ${var.server_node.name}",
    "--cluster-domain ${var.cluster_name}",
    "--cluster-cidr ${var.cluster_cidr.pods}",
    "--service-cidr ${var.cluster_cidr.services}",
    "--token ${random_password.k3s_cluster_secret.result}",
  ]
  server_labels_flags  = [for label, value in var.server_node.labels : "--node-label '${label}=${value}'" if value != null]
  server_taints_flags  = [for key, taint in var.server_node.taints : "--node-taint '${key}=${taint}'" if taint != null]
}

resource null_resource k3s_server {
  triggers = {
    install_args = sha1(join(" ", concat(local.server_labels_flags, local.server_default_flags, var.server_node.additional_flags)))
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

  # Remove old k3s installation
  provisioner remote-exec {
    inline = [
      "if ! command -V k3s-uninstall.sh > /dev/null; then exit; fi",
      "echo >&2 [WARN] K3s seems already installed on this node and will be uninstalled.",
      "k3s-uninstall.sh",
    ]
  }
}

resource null_resource k3s_server_installer {
  triggers = {
    server_init = null_resource.k3s_server.id
    version     = local.k3s_version
  }
  depends_on = [
  null_resource.k3s_server]

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

  # Upload k3s file
  provisioner file {
    content     = data.http.k3s_installer.body
    destination = "/tmp/k3s-installer"
  }

  # Install K3S server
  provisioner "remote-exec" {
    inline = [
      "INSTALL_K3S_VERSION=${local.k3s_version} sh /tmp/k3s-installer ${join(" ", concat(local.server_default_flags, var.server_node.additional_flags))}",
      "until kubectl get nodes | grep -v '[WARN] No resources found'; do sleep 1; done"
    ]
  }
}
