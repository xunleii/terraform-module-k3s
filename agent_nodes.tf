locals {
  // Generate a map of all agents annotations in order to manage them through this module. This
  // generation is made in two steps:
  // - generate a list of objects representing all annotations, following this
  //   'template' {key = node_name|annotation_name, value = annotation_value}
  // - generate a map based on the generated list (using the field key as map key)
  agent_annotations_list = flatten([
    for nk, nv in var.agents : [
      // Because we need node name and annotation name when we remove the annotation resource, we need
      // to share them through the annotation key (each.value are not avaible on destruction).
      for ak, av in try(nv.annotations, {}) : av == null ? { key : "" } : { key : "${nk}${var.separator}${ak}", value : av }
    ]
  ])
  agent_annotations = local.managed_annotation_enabled ? { for o in local.agent_annotations_list : o.key => o.value if o.key != "" } : {}

  // Generate a map of all agents labels in order to manage them through this module. This
  // generation is made in two steps, following the same process than annotation's map.
  agent_labels_list = flatten([
    for nk, nv in var.agents : [
      // Because we need node name and label name when we remove the label resource, we need
      // to share them through the label key (each.value are not avaible on destruction).
      for lk, lv in try(nv.labels, {}) : lv == null ? { key : "" } : { key : "${nk}${var.separator}${lk}", value : lv }
    ]
  ])
  agent_labels = local.managed_label_enabled ? { for o in local.agent_labels_list : o.key => o.value if o.key != "" } : {}

  // Generate a map of all agents taints in order to manage them through this module. This
  // generation is made in two steps, following the same process than annotation's map.
  agent_taints_list = flatten([
    for nk, nv in var.agents : [
      // Because we need node name and taint name when we remove the taint resource, we need
      // to share them through the taint key (each.value are not avaible on destruction).
      for tk, tv in try(nv.taints, {}) : tv == null ? { key : "" } : { key : "${nk}${var.separator}${tk}", value : tv }
    ]
  ])
  agent_taints = local.managed_taint_enabled ? { for o in local.agent_taints_list : o.key => o.value if o.key != "" } : {}

  // Generate a map of all calculated agent fields, used during k3s installation.
  agents_metadata = {
    for key, agent in var.agents :
    key => {
      name = try(agent.name, key)
      ip   = agent.ip

      flags = join(" ", compact(concat(
        [
          "--node-ip ${agent.ip}",
          "--node-name '${try(agent.name, key)}'",
          "--server https://${local.root_advertise_ip_k3s}:6443",
          "--token ${nonsensitive(random_password.k3s_cluster_secret.result)}", # NOTE: nonsensitive is used to show logs during provisioning
        ],
        var.global_flags,
        try(agent.flags, []),
        [for key, value in try(agent.taints, {}) : "--node-taint '${key}=${value}'" if value != null]
      )))

      immutable_fields_hash = sha1(join("", concat(
        [var.cluster_domain],
        var.global_flags,
        try(agent.flags, []),
      )))
    }
  }
  kubectl_cmd = var.use_sudo ? "sudo kubectl" : "kubectl"
}

// Install k3s agent
resource "null_resource" "agents_install" {
  for_each = var.agents

  depends_on = [null_resource.servers_install]
  triggers = {
    on_immutable_changes = local.agents_metadata[each.key].immutable_fields_hash
    on_new_version       = local.k3s_version
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

  // Upload k3s install script
  provisioner "file" {
    content     = data.http.k3s_installer.response_body
    destination = "/tmp/k3s-installer"
  }

  // Install k3s
  provisioner "remote-exec" {
    inline = [
      "${local.install_env_vars} INSTALL_K3S_VERSION=${local.k3s_version} sh /tmp/k3s-installer agent ${local.agents_metadata[each.key].flags}",
      "until systemctl is-active --quiet k3s-agent.service; do sleep 1; done"
    ]
  }
}

// Drain k3s node on destruction in order to safely move all workflows to another node.
resource "null_resource" "agents_drain" {
  for_each = var.agents

  depends_on = [null_resource.agents_install]
  triggers = {
    // Because some fields must be used on destruction, we need to store them into the current
    // object. The only way to do that is to use triggers to store theses fields.
    agent_name      = local.agents_metadata[split(var.separator, each.key)[0]].name
    connection_json = base64encode(jsonencode(local.root_server_connection))
    drain_timeout   = var.drain_timeout
    kubectl_cmd     = local.kubectl_cmd
  }
  // Because we use triggers as memory area, we need to ignore all changes on it.
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

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "${self.triggers.kubectl_cmd} drain ${self.triggers.agent_name} --delete-local-data --force --ignore-daemonsets --timeout=${self.triggers.drain_timeout}"
    ]
  }
}

// Add/remove manually annotation on k3s agent
resource "null_resource" "agents_annotation" {
  for_each = local.agent_annotations

  depends_on = [null_resource.agents_install]
  triggers = {
    agent_name       = local.agents_metadata[split(var.separator, each.key)[0]].name
    annotation_name  = split(var.separator, each.key)[1]
    on_value_changes = each.value

    // Because some fields must be used on destruction, we need to store them into the current
    // object. The only way to do that is to use triggers to store theses fields.
    connection_json = base64encode(jsonencode(local.root_server_connection))
    kubectl_cmd     = local.kubectl_cmd
  }
  // Because we dont care about connection modification, we ignore its changes.
  lifecycle { ignore_changes = [triggers["connection_json"], triggers["kubectl_cmd"]] }

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

  provisioner "remote-exec" {
    inline = [
      "until kubectl get node ${self.triggers.agent_name}; do sleep 1; done",
      "${self.triggers.kubectl_cmd} annotate --overwrite node ${self.triggers.agent_name} ${self.triggers.annotation_name}=${self.triggers.on_value_changes}"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "${self.triggers.kubectl_cmd} annotate node ${self.triggers.agent_name} ${self.triggers.annotation_name}-"
    ]
  }
}

// Add/remove manually label on k3s agent
resource "null_resource" "agents_label" {
  for_each = local.agent_labels

  depends_on = [null_resource.agents_install]
  triggers = {
    agent_name       = local.agents_metadata[split(var.separator, each.key)[0]].name
    label_name       = split(var.separator, each.key)[1]
    on_value_changes = each.value

    // Because some fields must be used on destruction, we need to store them into the current
    // object. The only way to do that is to use triggers to store theses fields.
    connection_json = base64encode(jsonencode(local.root_server_connection))
    kubectl_cmd     = local.kubectl_cmd
  }
  // Because we dont care about connection modification, we ignore its changes.
  lifecycle { ignore_changes = [triggers["connection_json"], triggers["kubectl_cmd"]] }

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

  provisioner "remote-exec" {
    inline = [
      "until ${self.triggers.kubectl_cmd} get node ${self.triggers.agent_name}; do sleep 1; done",
      "${self.triggers.kubectl_cmd} label --overwrite node ${self.triggers.agent_name} ${self.triggers.label_name}=${self.triggers.on_value_changes}"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "${self.triggers.kubectl_cmd} label node ${self.triggers.agent_name} ${self.triggers.label_name}-"
    ]
  }
}

// Add manually taint on k3s agent
resource "null_resource" "agents_taint" {
  for_each = local.agent_taints

  depends_on = [null_resource.agents_install]
  triggers = {
    agent_name       = local.agents_metadata[split(var.separator, each.key)[0]].name
    taint_name       = split(var.separator, each.key)[1]
    on_value_changes = each.value

    // Because some fields must be used on destruction, we need to store them into the current
    // object. The only way to do that is to use triggers to store theses fields.
    connection_json = base64encode(jsonencode(local.root_server_connection))
    kubectl_cmd     = local.kubectl_cmd
  }
  // Because we dont care about connection modification, we ignore its changes.
  lifecycle { ignore_changes = [triggers["connection_json"], triggers["kubectl_cmd"]] }

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

  provisioner "remote-exec" {
    inline = [
      "until ${self.triggers.kubectl_cmd} get node ${self.triggers.agent_name}; do sleep 1; done",
      "${self.triggers.kubectl_cmd} taint node ${self.triggers.agent_name} ${self.triggers.taint_name}=${self.triggers.on_value_changes} --overwrite"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "${self.triggers.kubectl_cmd} taint node ${self.triggers.agent_name} ${self.triggers.taint_name}-"
    ]
  }
}
