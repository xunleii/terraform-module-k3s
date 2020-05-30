locals {
  // Some vars use to easily access to the first k3s server values
  root_server_name = keys(var.servers)[0]
  root_server_ip   = values(var.servers)[0].ip
  root_server_connection = {
    type = try(var.servers[local.root_server_name].connection.type, "ssh")

    host     = try(var.servers[local.root_server_name].connection.host, var.servers[local.root_server_name].ip)
    user     = try(var.servers[local.root_server_name].connection.user, null)
    password = try(var.servers[local.root_server_name].connection.password, null)
    port     = try(var.servers[local.root_server_name].connection.port, null)
    timeout  = try(var.servers[local.root_server_name].connection.timeout, null)

    script_path    = try(var.servers[local.root_server_name].connection.script_path, null)
    private_key    = try(var.servers[local.root_server_name].connection.private_key, null)
    certificate    = try(var.servers[local.root_server_name].connection.certificate, null)
    agent          = try(var.servers[local.root_server_name].connection.agent, null)
    agent_identity = try(var.servers[local.root_server_name].connection.agent_identity, null)
    host_key       = try(var.servers[local.root_server_name].connection.host_key, null)

    https    = try(var.servers[local.root_server_name].connection.https, null)
    insecure = try(var.servers[local.root_server_name].connection.insecure, null)
    use_ntlm = try(var.servers[local.root_server_name].connection.use_ntlm, null)
    cacert   = try(var.servers[local.root_server_name].connection.cacert, null)

    bastion_host        = try(var.servers[local.root_server_name].connection.bastion_host, null)
    bastion_host_key    = try(var.servers[local.root_server_name].connection.bastion_host_key, null)
    bastion_port        = try(var.servers[local.root_server_name].connection.bastion_port, null)
    bastion_user        = try(var.servers[local.root_server_name].connection.bastion_user, null)
    bastion_password    = try(var.servers[local.root_server_name].connection.bastion_password, null)
    bastion_private_key = try(var.servers[local.root_server_name].connection.bastion_private_key, null)
    bastion_certificate = try(var.servers[local.root_server_name].connection.bastion_certificate, null)
  }

  // Generate a map of all servers annotations in order to manage them through this module. This
  // generation is made in two steps:
  // - generate a list of objects representing all annotations, following this
  //   'template' {key = node_name|annotation_name, value = annotation_value}
  // - generate a map based on the generated list (using the field key as map key)
  server_annotations_list = flatten([
    for nk, nv in var.servers : [
      // Because we need node name and annotation name when we remove the annotation resource, we need
      // to share them through the annotation key (each.value are not avaible on destruction).
      for ak, av in try(nv.annotations, {}) : av == null ? { key : "" } : { key : "${nk}${var.separator}${ak}", value : av }
    ]
  ])
  server_annotations = local.managed_annotation_enabled ? { for o in local.server_annotations_list : o.key => o.value if o.key != "" } : {}

  // Generate a map of all servers labels in order to manage them through this module. This
  // generation is made in two steps, following the same process than annotation's map.
  server_labels_list = flatten([
    for nk, nv in var.servers : [
      // Because we need node name and label name when we remove the label resource, we need
      // to share them through the label key (each.value are not avaible on destruction).
      for lk, lv in try(nv.labels, {}) : lv == null ? { key : "" } : { key : "${nk}${var.separator}${lk}", value : lv }
    ]
  ])
  server_labels = local.managed_label_enabled ? { for o in local.server_labels_list : o.key => o.value if o.key != "" } : {}

  // Generate a map of all servers taints in order to manage them through this module. This
  // generation is made in two steps, following the same process than annotation's map.
  server_taints_list = flatten([
    for nk, nv in var.servers : [
      // Because we need node name and taint name when we remove the taint resource, we need
      // to share them through the taint key (each.value are not avaible on destruction).
      for tk, tv in try(nv.taints, {}) : tv == null ? { key : "" } : { key : "${nk}${var.separator}${tk}", value : tv }
    ]
  ])
  server_taints = local.managed_taint_enabled ? { for o in local.server_taints_list : o.key => o.value if o.key != "" } : {}

  // Generate a map of all calculed server fields, used during k3s installation.
  servers_metadata = {
    for key, server in var.servers :
    key => {
      name = try(server.name, key)
      ip   = server.ip

      flags = join(" ", compact(concat(
        key == local.root_server_name ?
        // For the first server node, add all configuration flags
        [
          "--node-ip ${server.ip}",
          "--node-name '${try(server.name, key)}'",
          "--cluster-domain '${var.name}'",
          "--cluster-cidr ${var.cidr.pods}",
          "--service-cidr ${var.cidr.services}",
          "--token ${random_password.k3s_cluster_secret.result}",
          length(var.servers) > 1 ? "--cluster-init" : "",
        ] :
        // For other server nodes, use agent flags (because the first node manage the cluster configuration)
        [
          "--node-ip ${server.ip}",
          "--node-name '${try(server.name, key)}'",
          "--server https://${local.root_server_ip}:6443",
          "--token ${random_password.k3s_cluster_secret.result}",
        ],
        var.global_flags,
        try(server.flags, []),
        [for key, value in try(server.labels, {}) : "--node-label '${key}=${value}'" if value != null],
        [for key, value in try(server.taints, {}) : "--node-taint '${key}=${value}'" if value != null]
      )))

      immutable_fields_hash = sha1(join("", concat(
        [var.name, var.cidr.pods, var.cidr.services, local.k3s_version],
        var.global_flags,
        try(server.flags, []),
      )))
    }
  }
}

// Install k3s server
resource null_resource k3s_servers_install {
  for_each = var.servers
  triggers = {
    on_immutable_fields_changes = local.servers_metadata[each.key].immutable_fields_hash
  }

  connection {
    type = try(each.value.connection.type, "ssh")

    host     = try(each.value.connection.host, each.value.ip)
    user     = try(each.value.connection.user, null)
    password = try(each.value.connection.password, null)
    port     = try(each.value.connection.port, null)
    timeout  = try(each.value.connection.timeout, null)

    script_path    = try(each.value.connection.script_path, null)
    private_key    = try(each.value.connection.private_key, null)
    certificate    = try(each.value.connection.certificate, null)
    agent          = try(each.value.connection.agent, null)
    agent_identity = try(each.value.connection.agent_identity, null)
    host_key       = try(each.value.connection.host_key, null)

    https    = try(each.value.connection.https, null)
    insecure = try(each.value.connection.insecure, null)
    use_ntlm = try(each.value.connection.use_ntlm, null)
    cacert   = try(each.value.connection.cacert, null)

    bastion_host        = try(each.value.connection.bastion_host, null)
    bastion_host_key    = try(each.value.connection.bastion_host_key, null)
    bastion_port        = try(each.value.connection.bastion_port, null)
    bastion_user        = try(each.value.connection.bastion_user, null)
    bastion_password    = try(each.value.connection.bastion_password, null)
    bastion_private_key = try(each.value.connection.bastion_private_key, null)
    bastion_certificate = try(each.value.connection.bastion_certificate, null)
  }

  // Upload k3s file
  provisioner file {
    content     = data.http.k3s_installer.body
    destination = "/tmp/k3s-installer"
  }

  // Remove old k3s installation
  provisioner remote-exec {
    inline = [
      "if ! command -V k3s-uninstall.sh > /dev/null; then exit; fi",
      "echo >&2 [WARN] K3s seems already installed on this node and will be uninstalled.",
      "k3s-uninstall.sh",
    ]
  }

  // Install k3s server
  provisioner "remote-exec" {
    inline = [
      "INSTALL_K3S_VERSION=${local.k3s_version} sh /tmp/k3s-installer ${local.servers_metadata[each.key].flags}",
      "until kubectl get nodes; do sleep 5; done"
    ]
  }
}

// Drain k3s node on destruction in order to safely move all workflows to another node.
resource null_resource server_drain {
  for_each = var.servers

  depends_on = [null_resource.k3s_servers_install]
  triggers = {
    server_name     = local.servers_metadata[split(var.separator, each.key)[0]].name
    connection_json = base64encode(jsonencode(local.root_server_connection))
    drain_timeout   = var.drain_timeout
  }
  lifecycle { ignore_changes = [triggers] }

  connection {
    type = jsondecode(base64decode(self.triggers.connection_json)).type

    host     = jsondecode(base64decode(self.triggers.connection_json)).host
    user     = jsondecode(base64decode(self.triggers.connection_json)).user
    password = jsondecode(base64decode(self.triggers.connection_json)).password
    port     = jsondecode(base64decode(self.triggers.connection_json)).port
    timeout  = jsondecode(base64decode(self.triggers.connection_json)).timeout

    script_path    = jsondecode(base64decode(self.triggers.connection_json)).script_path
    private_key    = jsondecode(base64decode(self.triggers.connection_json)).private_key
    certificate    = jsondecode(base64decode(self.triggers.connection_json)).certificate
    agent          = jsondecode(base64decode(self.triggers.connection_json)).agent
    agent_identity = jsondecode(base64decode(self.triggers.connection_json)).agent_identity
    host_key       = jsondecode(base64decode(self.triggers.connection_json)).host_key

    https    = jsondecode(base64decode(self.triggers.connection_json)).https
    insecure = jsondecode(base64decode(self.triggers.connection_json)).insecure
    use_ntlm = jsondecode(base64decode(self.triggers.connection_json)).use_ntlm
    cacert   = jsondecode(base64decode(self.triggers.connection_json)).cacert

    bastion_host        = jsondecode(base64decode(self.triggers.connection_json)).bastion_host
    bastion_host_key    = jsondecode(base64decode(self.triggers.connection_json)).bastion_host_key
    bastion_port        = jsondecode(base64decode(self.triggers.connection_json)).bastion_port
    bastion_user        = jsondecode(base64decode(self.triggers.connection_json)).bastion_user
    bastion_password    = jsondecode(base64decode(self.triggers.connection_json)).bastion_password
    bastion_private_key = jsondecode(base64decode(self.triggers.connection_json)).bastion_private_key
    bastion_certificate = jsondecode(base64decode(self.triggers.connection_json)).bastion_certificate
  }

  provisioner remote-exec {
    when   = destroy
    inline = ["kubectl drain ${self.triggers.server_name} --delete-local-data --force --ignore-daemonsets --timeout=${self.triggers.drain_timeout}"]
  }
}

// Add/remove manually annotation on k3s server
resource null_resource k3s_servers_annotation {
  for_each = local.server_annotations

  depends_on = [null_resource.k3s_servers_install]
  triggers = {
    server_name      = local.servers_metadata[split(var.separator, each.key)[0]].name
    annotation_name  = split(var.separator, each.key)[1]
    on_install       = null_resource.k3s_servers_install[split(var.separator, each.key)[0]].id
    on_value_changes = each.value

    connection_json = base64encode(jsonencode(local.root_server_connection))
  }
  lifecycle { ignore_changes = [triggers["connection_json"]] }

  connection {
    type = jsondecode(base64decode(self.triggers.connection_json)).type

    host     = jsondecode(base64decode(self.triggers.connection_json)).host
    user     = jsondecode(base64decode(self.triggers.connection_json)).user
    password = jsondecode(base64decode(self.triggers.connection_json)).password
    port     = jsondecode(base64decode(self.triggers.connection_json)).port
    timeout  = jsondecode(base64decode(self.triggers.connection_json)).timeout

    script_path    = jsondecode(base64decode(self.triggers.connection_json)).script_path
    private_key    = jsondecode(base64decode(self.triggers.connection_json)).private_key
    certificate    = jsondecode(base64decode(self.triggers.connection_json)).certificate
    agent          = jsondecode(base64decode(self.triggers.connection_json)).agent
    agent_identity = jsondecode(base64decode(self.triggers.connection_json)).agent_identity
    host_key       = jsondecode(base64decode(self.triggers.connection_json)).host_key

    https    = jsondecode(base64decode(self.triggers.connection_json)).https
    insecure = jsondecode(base64decode(self.triggers.connection_json)).insecure
    use_ntlm = jsondecode(base64decode(self.triggers.connection_json)).use_ntlm
    cacert   = jsondecode(base64decode(self.triggers.connection_json)).cacert

    bastion_host        = jsondecode(base64decode(self.triggers.connection_json)).bastion_host
    bastion_host_key    = jsondecode(base64decode(self.triggers.connection_json)).bastion_host_key
    bastion_port        = jsondecode(base64decode(self.triggers.connection_json)).bastion_port
    bastion_user        = jsondecode(base64decode(self.triggers.connection_json)).bastion_user
    bastion_password    = jsondecode(base64decode(self.triggers.connection_json)).bastion_password
    bastion_private_key = jsondecode(base64decode(self.triggers.connection_json)).bastion_private_key
    bastion_certificate = jsondecode(base64decode(self.triggers.connection_json)).bastion_certificate
  }

  provisioner remote-exec {
    inline = [
    "kubectl annotate --overwrite node ${self.triggers.server_name} ${self.triggers.annotation_name}=${self.triggers.on_value_changes}"]
  }

  provisioner remote-exec {
    when = destroy
    inline = [
    "kubectl annotate node ${self.triggers.server_name} ${self.triggers.annotation_name}-"]
  }
}

// Add/remove manually label on k3s server
resource null_resource k3s_servers_label {
  for_each = local.server_labels

  depends_on = [null_resource.k3s_servers_install]
  triggers = {
    server_name      = local.servers_metadata[split(var.separator, each.key)[0]].name
    label_name       = split(var.separator, each.key)[1]
    on_install       = null_resource.k3s_servers_install[split(var.separator, each.key)[0]].id
    on_value_changes = each.value

    connection_json = base64encode(jsonencode(local.root_server_connection))
  }
  lifecycle { ignore_changes = [triggers["connection_json"]] }

  connection {
    type = jsondecode(base64decode(self.triggers.connection_json)).type

    host     = jsondecode(base64decode(self.triggers.connection_json)).host
    user     = jsondecode(base64decode(self.triggers.connection_json)).user
    password = jsondecode(base64decode(self.triggers.connection_json)).password
    port     = jsondecode(base64decode(self.triggers.connection_json)).port
    timeout  = jsondecode(base64decode(self.triggers.connection_json)).timeout

    script_path    = jsondecode(base64decode(self.triggers.connection_json)).script_path
    private_key    = jsondecode(base64decode(self.triggers.connection_json)).private_key
    certificate    = jsondecode(base64decode(self.triggers.connection_json)).certificate
    agent          = jsondecode(base64decode(self.triggers.connection_json)).agent
    agent_identity = jsondecode(base64decode(self.triggers.connection_json)).agent_identity
    host_key       = jsondecode(base64decode(self.triggers.connection_json)).host_key

    https    = jsondecode(base64decode(self.triggers.connection_json)).https
    insecure = jsondecode(base64decode(self.triggers.connection_json)).insecure
    use_ntlm = jsondecode(base64decode(self.triggers.connection_json)).use_ntlm
    cacert   = jsondecode(base64decode(self.triggers.connection_json)).cacert

    bastion_host        = jsondecode(base64decode(self.triggers.connection_json)).bastion_host
    bastion_host_key    = jsondecode(base64decode(self.triggers.connection_json)).bastion_host_key
    bastion_port        = jsondecode(base64decode(self.triggers.connection_json)).bastion_port
    bastion_user        = jsondecode(base64decode(self.triggers.connection_json)).bastion_user
    bastion_password    = jsondecode(base64decode(self.triggers.connection_json)).bastion_password
    bastion_private_key = jsondecode(base64decode(self.triggers.connection_json)).bastion_private_key
    bastion_certificate = jsondecode(base64decode(self.triggers.connection_json)).bastion_certificate
  }

  provisioner remote-exec {
    inline = [
    "kubectl label --overwrite node ${self.triggers.server_name} ${self.triggers.label_name}=${self.triggers.on_value_changes}"]
  }

  provisioner remote-exec {
    when = destroy
    inline = [
    "kubectl label node ${self.triggers.server_name} ${self.triggers.label_name}-"]
  }
}

// Add/remove manually taint on k3s server
resource null_resource k3s_servers_taint {
  for_each = local.server_taints

  depends_on = [null_resource.k3s_servers_install]
  triggers = {
    server_name      = local.servers_metadata[split(var.separator, each.key)[0]].name
    taint_name       = split(var.separator, each.key)[1]
    connection_json  = base64encode(jsonencode(local.root_server_connection))
    on_install       = null_resource.k3s_servers_install[split(var.separator, each.key)[0]].id
    on_value_changes = each.value

    connection_json = base64encode(jsonencode(local.root_server_connection))
  }
  lifecycle { ignore_changes = [triggers["connection_json"]] }

  connection {
    type = jsondecode(base64decode(self.triggers.connection_json)).type

    host     = jsondecode(base64decode(self.triggers.connection_json)).host
    user     = jsondecode(base64decode(self.triggers.connection_json)).user
    password = jsondecode(base64decode(self.triggers.connection_json)).password
    port     = jsondecode(base64decode(self.triggers.connection_json)).port
    timeout  = jsondecode(base64decode(self.triggers.connection_json)).timeout

    script_path    = jsondecode(base64decode(self.triggers.connection_json)).script_path
    private_key    = jsondecode(base64decode(self.triggers.connection_json)).private_key
    certificate    = jsondecode(base64decode(self.triggers.connection_json)).certificate
    agent          = jsondecode(base64decode(self.triggers.connection_json)).agent
    agent_identity = jsondecode(base64decode(self.triggers.connection_json)).agent_identity
    host_key       = jsondecode(base64decode(self.triggers.connection_json)).host_key

    https    = jsondecode(base64decode(self.triggers.connection_json)).https
    insecure = jsondecode(base64decode(self.triggers.connection_json)).insecure
    use_ntlm = jsondecode(base64decode(self.triggers.connection_json)).use_ntlm
    cacert   = jsondecode(base64decode(self.triggers.connection_json)).cacert

    bastion_host        = jsondecode(base64decode(self.triggers.connection_json)).bastion_host
    bastion_host_key    = jsondecode(base64decode(self.triggers.connection_json)).bastion_host_key
    bastion_port        = jsondecode(base64decode(self.triggers.connection_json)).bastion_port
    bastion_user        = jsondecode(base64decode(self.triggers.connection_json)).bastion_user
    bastion_password    = jsondecode(base64decode(self.triggers.connection_json)).bastion_password
    bastion_private_key = jsondecode(base64decode(self.triggers.connection_json)).bastion_private_key
    bastion_certificate = jsondecode(base64decode(self.triggers.connection_json)).bastion_certificate
  }

  provisioner remote-exec {
    inline = [
    "kubectl taint node ${self.triggers.server_name} ${self.triggers.taint_name}=${self.triggers.on_value_changes} --overwrite"]
  }

  provisioner remote-exec {
    when = destroy
    inline = [
    "kubectl taint node ${self.triggers.server_name} ${self.triggers.taint_name}-"]
  }
}
