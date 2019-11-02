locals {
  minion_install_opts = [
    "INSTALL_K3S_VERSION=${local.k3s_version}",
    "K3S_URL=https://${var.master_node.ip}:6443",
    "K3S_TOKEN=$(cat /etc/rancher/k3s/server/node-token)"
  ]
  minion_install_opt = join(" ", local.minion_install_opts)
}


resource "null_resource" "k3s_minions" {
  count = length(var.minion_nodes)

  triggers = {
    master_init  = null_resource.k3s_master.id
    minion_ip    = sha1(element(var.minion_nodes.*.ip, count.index))
    minion_input = sha1(lookup(element(var.minion_nodes.*.connection, count.index), "host", element(var.minion_nodes.*.ip, count.index)))
  }
  depends_on = [null_resource.k3s_master_installer]

  connection {
    type = lookup(element(var.minion_nodes.*.connection, count.index), "type", "ssh")

    host     = lookup(element(var.minion_nodes.*.connection, count.index), "host", element(var.minion_nodes.*.ip, count.index))
    user     = lookup(element(var.minion_nodes.*.connection, count.index), "user", null)
    password = lookup(element(var.minion_nodes.*.connection, count.index), "password", null)
    port     = lookup(element(var.minion_nodes.*.connection, count.index), "port", null)
    timeout  = lookup(element(var.minion_nodes.*.connection, count.index), "timeout", null)

    script_path    = lookup(element(var.minion_nodes.*.connection, count.index), "script_path", null)
    private_key    = lookup(element(var.minion_nodes.*.connection, count.index), "private_key", null)
    certificate    = lookup(element(var.minion_nodes.*.connection, count.index), "certificate", null)
    agent          = lookup(element(var.minion_nodes.*.connection, count.index), "agent", null)
    agent_identity = lookup(element(var.minion_nodes.*.connection, count.index), "agent_identity", null)
    host_key       = lookup(element(var.minion_nodes.*.connection, count.index), "host_key", null)

    # NOTE: Currently not working on Windows machines
    # https    = lookup(element(var.minion_nodes.*.connection, count.index), "https", null)
    # insecure = lookup(element(var.minion_nodes.*.connection, count.index), "insecure", null)
    # use_ntlm = lookup(element(var.minion_nodes.*.connection, count.index), "use_ntlm", null)
    # cacert   = lookup(element(var.minion_nodes.*.connection, count.index), "cacert", null)

    bastion_host        = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_host", null)
    bastion_host_key    = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_host_key", null)
    bastion_port        = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_port", null)
    bastion_user        = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_user", null)
    bastion_password    = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_password", null)
    bastion_private_key = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_private_key", null)
    bastion_certificate = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_certificate", null)
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
  count = length(var.minion_nodes)

  triggers = {
    master_node = null_resource.k3s_master_installer.id
    minion_init = element(null_resource.k3s_minions.*.id, count.index)
  }
  depends_on = [null_resource.k3s_minions]

  connection {
    type = lookup(element(var.minion_nodes.*.connection, count.index), "type", "ssh")

    host     = lookup(element(var.minion_nodes.*.connection, count.index), "host", element(var.minion_nodes.*.ip, count.index))
    user     = lookup(element(var.minion_nodes.*.connection, count.index), "user", null)
    password = lookup(element(var.minion_nodes.*.connection, count.index), "password", null)
    port     = lookup(element(var.minion_nodes.*.connection, count.index), "port", null)
    timeout  = lookup(element(var.minion_nodes.*.connection, count.index), "timeout", null)

    script_path    = lookup(element(var.minion_nodes.*.connection, count.index), "script_path", null)
    private_key    = lookup(element(var.minion_nodes.*.connection, count.index), "private_key", null)
    certificate    = lookup(element(var.minion_nodes.*.connection, count.index), "certificate", null)
    agent          = lookup(element(var.minion_nodes.*.connection, count.index), "agent", null)
    agent_identity = lookup(element(var.minion_nodes.*.connection, count.index), "agent_identity", null)
    host_key       = lookup(element(var.minion_nodes.*.connection, count.index), "host_key", null)

    # NOTE: Currently not working on Windows machines
    # https    = lookup(element(var.minion_nodes.*.connection, count.index), "https", null)
    # insecure = lookup(element(var.minion_nodes.*.connection, count.index), "insecure", null)
    # use_ntlm = lookup(element(var.minion_nodes.*.connection, count.index), "use_ntlm", null)
    # cacert   = lookup(element(var.minion_nodes.*.connection, count.index), "cacert", null)

    bastion_host        = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_host", null)
    bastion_host_key    = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_host_key", null)
    bastion_port        = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_port", null)
    bastion_user        = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_user", null)
    bastion_password    = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_password", null)
    bastion_private_key = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_private_key", null)
    bastion_certificate = lookup(element(var.minion_nodes.*.connection, count.index), "bastion_certificate", null)
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | ${local.minion_install_opt} sh -s - --node-ip ${element(var.minion_nodes.*.ip, count.index)}"
    ]
  }
}
