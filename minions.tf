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
    master    = null_resource.k3s_master.id
    minion_ip = each.value.ip
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
      "if command -V k3s-agent-uninstall.sh > /dev/null; then k3s-agent-uninstall.sh; fi",
      "echo >&2 [NOTE] Importing node-token is mandatory and require some SSH configuration.",
      "echo >&2 [NOTE] If the next command fails, feel free to open an issue on the module repository.",
      "echo >&2 [NOTE] This behaviour will change only when we are able to download a file from the remote.",
      "rm -rf /etc/rancher/k3s/server",
      "mkdir -p /etc/rancher/k3s/server",
      "scp -P ${lookup(var.master_node.connection, "port", "22")} -o 'StrictHostKeyChecking no' ${lookup(var.master_node.connection, "user", "root")}@${var.master_node.ip}:/var/lib/rancher/k3s/server/node-token /etc/rancher/k3s/server",
    ]
  }
}

resource "null_resource" "k3s_minions_installer" {
  for_each = var.minion_nodes

  triggers = {
    master = null_resource.k3s_master_installer.id
    minion = null_resource.k3s_minions[each.key].id
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

resource "null_resource" "k3s_minions_uninstaller" {
  for_each = var.minion_nodes

  triggers = {
    minion    = null_resource.k3s_minions[each.key].id
    minion_ip = each.value.ip
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

    # NOTE: Currently not working on Windows machines
    # https    = lookup(var.master_node.connection, "https", null)
    # insecure = lookup(var.master_node.connection, "insecure", null)
    # use_ntlm = lookup(var.master_node.connection, "use_ntlm", null)
    # cacert   = lookup(var.master_node.connection, "cacert", null)

    bastion_host        = lookup(var.master_node.connection, "bastion_host", null)
    bastion_host_key    = lookup(var.master_node.connection, "bastion_host_key", null)
    bastion_port        = lookup(var.master_node.connection, "bastion_port", null)
    bastion_user        = lookup(var.master_node.connection, "bastion_user", null)
    bastion_password    = lookup(var.master_node.connection, "bastion_password", null)
    bastion_private_key = lookup(var.master_node.connection, "bastion_private_key", null)
    bastion_certificate = lookup(var.master_node.connection, "bastion_certificate", null)
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "NODE=$(kubectl get node -l 'k3s.io/internal-ip = ${self.triggers.minion_ip}' | tail -n 1 | awk '{printf $1}')",
      "kubectl drain $${NODE} --force --delete-local-data --ignore-daemonsets",
      "kubectl delete node $${NODE}",
      "sed -i \"/$${NODE}$/d\" /var/lib/rancher/k3s/server/cred/node-passwd",
    ]
  }
}
