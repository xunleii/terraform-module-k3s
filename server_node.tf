// - Server metadata cache
locals {
  server_required_flags = [
    "--node-ip ${var.server.ip}",
    "--node-name '${var.server.name}'",
    "--cluster-domain '${var.name}'",
    "--cluster-cidr ${var.cidr.pods}",
    "--service-cidr ${var.cidr.services}",
    "--token ${random_password.k3s_cluster_secret.result}",
  ]
}

data null_data_source server_metadata {
  inputs = {
    name = var.server.name
    ip   = var.server.ip

    flags = join(" ", compact(concat(
      local.server_required_flags,
      var.global_flags,
      try(var.server.flags, []),
      [for key, value in try(var.server.labels, {}) : "--node-label '${key}=${value}'" if value != null],
      [for key, value in try(var.server.taints, {}) : "--node-taint '${key}=${value}'" if value != null]
    )))

    mutable_flags_hash = sha1(join("", concat(
      [for key, value in try(var.server.labels, {}) : "--node-label '${key}=${value}'" if value != null],
      [for key, value in try(var.server.taints, {}) : "--node-taint '${key}=${value}'" if value != null]
    )))
    immutable_flags_hash = sha1(join("", concat(
      local.server_required_flags,
      var.global_flags,
      try(var.server.flags)
    )))
  }
}

// - Server installation
resource null_resource k3s_server_install {
  triggers = {
    on_immutable_flags_changes = data.null_data_source.server_metadata.outputs.immutable_flags_hash
  }

  connection {
    type = try(var.server.connection.type, "ssh")

    host     = try(var.server.connection.host, var.server.ip)
    user     = try(var.server.connection.user, null)
    password = try(var.server.connection.password, null)
    port     = try(var.server.connection.port, null)
    timeout  = try(var.server.connection.timeout, null)

    script_path    = try(var.server.connection.script_path, null)
    private_key    = try(var.server.connection.private_key, null)
    certificate    = try(var.server.connection.certificate, null)
    agent          = try(var.server.connection.agent, null)
    agent_identity = try(var.server.connection.agent_identity, null)
    host_key       = try(var.server.connection.host_key, null)

    https    = try(var.server.connection.https, null)
    insecure = try(var.server.connection.insecure, null)
    use_ntlm = try(var.server.connection.use_ntlm, null)
    cacert   = try(var.server.connection.cacert, null)

    bastion_host        = try(var.server.connection.bastion_host, null)
    bastion_host_key    = try(var.server.connection.bastion_host_key, null)
    bastion_port        = try(var.server.connection.bastion_port, null)
    bastion_user        = try(var.server.connection.bastion_user, null)
    bastion_password    = try(var.server.connection.bastion_password, null)
    bastion_private_key = try(var.server.connection.bastion_private_key, null)
    bastion_certificate = try(var.server.connection.bastion_certificate, null)
  }

  # Upload k3s file
  provisioner file {
    content     = data.http.k3s_installer.body
    destination = "/tmp/k3s-installer"
  }

  # Remove old k3s installation
  provisioner remote-exec {
    inline = [
      "if ! command -V k3s-uninstall.sh > /dev/null; then exit; fi",
      "echo >&2 [WARN] K3s seems already installed on this node and will be uninstalled.",
      "k3s-uninstall.sh",
    ]
  }

  # Install k3s server
  provisioner "remote-exec" {
    inline = [
      "INSTALL_K3S_VERSION=${local.k3s_version} sh /tmp/k3s-installer ${data.null_data_source.server_metadata.outputs.flags}",
      "until kubectl get nodes | grep -v '[WARN] No resources found'; do sleep 1; done"
    ]
  }
}

// - Server annotation, label and taint management
# Add manually annotation on k3s server (not updated when k3s restart with new annotations)
resource null_resource k3s_server_label {
  for_each = try(var.server.annotations, {})

  depends_on = [
  null_resource.k3s_server_install]
  triggers = {
    on_install       = null_resource.k3s_server_install.id
    on_value_changes = var.server.labels[each.key]
  }

  connection {
    type = try(var.server.connection.type, "ssh")

    host     = try(var.server.connection.host, var.server.ip)
    user     = try(var.server.connection.user, null)
    password = try(var.server.connection.password, null)
    port     = try(var.server.connection.port, null)
    timeout  = try(var.server.connection.timeout, null)

    script_path    = try(var.server.connection.script_path, null)
    private_key    = try(var.server.connection.private_key, null)
    certificate    = try(var.server.connection.certificate, null)
    agent          = try(var.server.connection.agent, null)
    agent_identity = try(var.server.connection.agent_identity, null)
    host_key       = try(var.server.connection.host_key, null)

    https    = try(var.server.connection.https, null)
    insecure = try(var.server.connection.insecure, null)
    use_ntlm = try(var.server.connection.use_ntlm, null)
    cacert   = try(var.server.connection.cacert, null)

    bastion_host        = try(var.server.connection.bastion_host, null)
    bastion_host_key    = try(var.server.connection.bastion_host_key, null)
    bastion_port        = try(var.server.connection.bastion_port, null)
    bastion_user        = try(var.server.connection.bastion_user, null)
    bastion_password    = try(var.server.connection.bastion_password, null)
    bastion_private_key = try(var.server.connection.bastion_private_key, null)
    bastion_certificate = try(var.server.connection.bastion_certificate, null)
  }

  provisioner remote-exec {
    inline = [
    "kubectl annotate node --overwrite ${data.null_data_source.server_metadata.outputs.name} ${each.key}=${each.value}"]
  }

  provisioner remote-exec {
    when = destroy
    inline = [
    "kubectl annotate node ${data.null_data_source.server_metadata.outputs.name} ${each.key}-"]
  }
}

# Add manually taint on k3s server (not updated when k3s restart with new taints)
resource null_resource k3s_server_taint {
  for_each = try(var.server.taints, {})

  depends_on = [
  null_resource.k3s_server_install]
  triggers = {
    on_install       = null_resource.k3s_server_install.id
    on_value_changes = var.server.taints[each.key]
  }

  connection {
    type = try(var.server.connection.type, "ssh")

    host     = try(var.server.connection.host, var.server.ip)
    user     = try(var.server.connection.user, null)
    password = try(var.server.connection.password, null)
    port     = try(var.server.connection.port, null)
    timeout  = try(var.server.connection.timeout, null)

    script_path    = try(var.server.connection.script_path, null)
    private_key    = try(var.server.connection.private_key, null)
    certificate    = try(var.server.connection.certificate, null)
    agent          = try(var.server.connection.agent, null)
    agent_identity = try(var.server.connection.agent_identity, null)
    host_key       = try(var.server.connection.host_key, null)

    https    = try(var.server.connection.https, null)
    insecure = try(var.server.connection.insecure, null)
    use_ntlm = try(var.server.connection.use_ntlm, null)
    cacert   = try(var.server.connection.cacert, null)

    bastion_host        = try(var.server.connection.bastion_host, null)
    bastion_host_key    = try(var.server.connection.bastion_host_key, null)
    bastion_port        = try(var.server.connection.bastion_port, null)
    bastion_user        = try(var.server.connection.bastion_user, null)
    bastion_password    = try(var.server.connection.bastion_password, null)
    bastion_private_key = try(var.server.connection.bastion_private_key, null)
    bastion_certificate = try(var.server.connection.bastion_certificate, null)
  }

  provisioner remote-exec {
    inline = [
    "kubectl taint node ${data.null_data_source.server_metadata.outputs.name} ${each.key}=${each.value} --overwrite"]
  }

  provisioner remote-exec {
    when = destroy
    inline = [
    "kubectl taint node ${data.null_data_source.server_metadata.outputs.name} ${each.key}-"]
  }
}

# Add manually taint on k3s server (not updated when k3s restart with new taints)
resource null_resource k3s_server_taint {
  for_each = try(var.server.taints, {})

  depends_on = [
  null_resource.k3s_server_install]
  triggers = {
    on_install       = null_resource.k3s_server_install.id
    on_value_changes = var.server.taints[each.key]
  }

  connection {
    type = try(var.server.connection.type, "ssh")

    host     = try(var.server.connection.host, var.server.ip)
    user     = try(var.server.connection.user, null)
    password = try(var.server.connection.password, null)
    port     = try(var.server.connection.port, null)
    timeout  = try(var.server.connection.timeout, null)

    script_path    = try(var.server.connection.script_path, null)
    private_key    = try(var.server.connection.private_key, null)
    certificate    = try(var.server.connection.certificate, null)
    agent          = try(var.server.connection.agent, null)
    agent_identity = try(var.server.connection.agent_identity, null)
    host_key       = try(var.server.connection.host_key, null)

    https    = try(var.server.connection.https, null)
    insecure = try(var.server.connection.insecure, null)
    use_ntlm = try(var.server.connection.use_ntlm, null)
    cacert   = try(var.server.connection.cacert, null)

    bastion_host        = try(var.server.connection.bastion_host, null)
    bastion_host_key    = try(var.server.connection.bastion_host_key, null)
    bastion_port        = try(var.server.connection.bastion_port, null)
    bastion_user        = try(var.server.connection.bastion_user, null)
    bastion_password    = try(var.server.connection.bastion_password, null)
    bastion_private_key = try(var.server.connection.bastion_private_key, null)
    bastion_certificate = try(var.server.connection.bastion_certificate, null)
  }

  provisioner remote-exec {
    inline = [
    "kubectl taint node ${data.null_data_source.server_metadata.outputs.name} ${each.key}=${each.value} --overwrite"]
  }

  provisioner remote-exec {
    when = destroy
    inline = [
    "kubectl taint node ${data.null_data_source.server_metadata.outputs.name} ${each.key}-"]
  }
}