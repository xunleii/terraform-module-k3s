locals {
  minion_install_opts = [
    "INSTALL_K3S_VERSION=${local.k3s_version}",
    "K3S_URL=https://${var.master_node.ip}:6443",
    "K3S_TOKEN=$(cat /etc/rancher/k3s/server/node-token)"
  ]
  minion_install_opt = join(" ", local.minion_install_opts)
}


resource "null_resource" "k3s_minions" {
  for_each = var.minion_nodes

  triggers = {
    master_init  = null_resource.k3s_master.id
    minion_ip    = sha1(each.value.ip)
    minion_input = sha1(lookup(each.value.connection, "host", each.value.ip))
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

    # NOTE: Currently not working on Windows machines
    # https    = lookup(each.value.connection, "https", null)
    # insecure = lookup(each.value.connection, "insecure", null)
    # use_ntlm = lookup(each.value.connection, "use_ntlm", null)
    # cacert   = lookup(each.value.connection, "cacert", null)

    bastion_host        = lookup(each.value.connection, "bastion_host", null)
    bastion_host_key    = lookup(each.value.connection, "bastion_host_key", null)
    bastion_port        = lookup(each.value.connection, "bastion_port", null)
    bastion_user        = lookup(each.value.connection, "bastion_user", null)
    bastion_password    = lookup(each.value.connection, "bastion_password", null)
    bastion_private_key = lookup(each.value.connection, "bastion_private_key", null)
    bastion_certificate = lookup(each.value.connection, "bastion_certificate", null)
  }

  provisioner "remote-exec" {
    inline = [
      "if ! command -V curl > /dev/null; then echo >&2 '[ERROR] curl must be installed to continue...'; exit 127; fi",
      "echo >&2 [NOTE] Importing node-token is mandatory and require some SSH configuration.",
      "echo >&2 [NOTE] If the next command fails, feel free to open an issue on the module repository.",
      "echo >&2 [NOTE] This behaviour will change only when we are able to download a file from the remote.",
      "rm -rf /etc/rancher/k3s/server",
      "mkdir -p /etc/rancher/k3s/server",
      "scp -P ${lookup(var.master_node.connection, "port", "22")} -o 'StrictHostKeyChecking no' ${lookup(var.master_node.connection, "user", "root")}@${var.master_node.ip}:/var/lib/rancher/k3s/server/node-token /etc/rancher/k3s/server",
      "scp -P ${lookup(var.master_node.connection, "port", "22")} -o 'StrictHostKeyChecking no' ${lookup(var.master_node.connection, "user", "root")}@${var.master_node.ip}:/etc/rancher/k3s/k3s.yaml /etc/rancher/k3s/k3s.yaml",
      "sed -i 's|https://127.0.0.1:6443|https://${var.master_node.ip}:6443|g' /etc/rancher/k3s/k3s.yaml",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "([ -f /usr/local/bin/k3s-agent-uninstall.sh ] && /usr/local/bin/k3s-agent-uninstall.sh) || echo >&2 '[ERROR] failed to uninstall k3s ... skip'",
    ]
  }
}

resource "null_resource" "k3s_minions_installer" {
  for_each = var.minion_nodes

  triggers = {
    master_node = null_resource.k3s_master_installer.id
    minion_init = lookup(null_resource.k3s_minions, each.key).id
  }
  depends_on = [null_resource.k3s_minions]

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

    # NOTE: Currently not working on Windows machines
    # https    = lookup(each.value.connection, "https", null)
    # insecure = lookup(each.value.connection, "insecure", null)
    # use_ntlm = lookup(each.value.connection, "use_ntlm", null)
    # cacert   = lookup(each.value.connection, "cacert", null)

    bastion_host        = lookup(each.value.connection, "bastion_host", null)
    bastion_host_key    = lookup(each.value.connection, "bastion_host_key", null)
    bastion_port        = lookup(each.value.connection, "bastion_port", null)
    bastion_user        = lookup(each.value.connection, "bastion_user", null)
    bastion_password    = lookup(each.value.connection, "bastion_password", null)
    bastion_private_key = lookup(each.value.connection, "bastion_private_key", null)
    bastion_certificate = lookup(each.value.connection, "bastion_certificate", null)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | ${local.minion_install_opt} sh -s - --node-ip ${each.value.ip}"
    ]
  }
}
