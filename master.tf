resource "null_resource" "k3s-master" {
  triggers = {
    uniq_sha = sha1(join("", [var.cluster_name, var.cluster_cidr, var.cluster_service_cidr]))
    master   = "${sha1(jsonencode(var.master_node))}"
  }

  connection {
    host = "${lookup(var.master_node.connection, "host", var.master_node.ip)}"

    type        = "${lookup(var.master_node.connection, "type", "ssh")}"
    user        = "${lookup(var.master_node.connection, "user", null)}"
    password    = "${lookup(var.master_node.connection, "password", null)}"
    port        = "${lookup(var.master_node.connection, "port", null)}"
    timeout     = "${lookup(var.master_node.connection, "timeout", null)}"
    script_path = "${lookup(var.master_node.connection, "script_path", null)}"

    private_key    = "${lookup(var.master_node.connection, "private_key", null)}"
    certificate    = "${lookup(var.master_node.connection, "certificate", null)}"
    agent          = "${lookup(var.master_node.connection, "agent", null)}"
    agent_identity = "${lookup(var.master_node.connection, "agent_identity", null)}"
    host_key       = "${lookup(var.master_node.connection, "host_key", null)}"

    # NOTE: Currently not working on Windows machines
    # https    = "${lookup(var.master_node.connection, "https", null)}"
    # insecure = "${lookup(var.master_node.connection, "insecure", null)}"
    # use_ntlm = "${lookup(var.master_node.connection, "use_ntlm", null)}"
    # cacert   = "${lookup(var.master_node.connection, "cacert", null)}"

    bastion_host        = "${lookup(var.master_node.connection, "bastion_host", null)}"
    bastion_host_key    = "${lookup(var.master_node.connection, "bastion_host_key", null)}"
    bastion_port        = "${lookup(var.master_node.connection, "bastion_port", null)}"
    bastion_user        = "${lookup(var.master_node.connection, "bastion_user", null)}"
    bastion_password    = "${lookup(var.master_node.connection, "bastion_password", null)}"
    bastion_private_key = "${lookup(var.master_node.connection, "bastion_private_key", null)}"
    bastion_certificate = "${lookup(var.master_node.connection, "bastion_certificate", null)}"
  }

  provisioner "remote-exec" {
    inline = [
      "if ! command -V curl > /dev/null; then echo >&2 '[ERROR] curl must be installed to continue...'; exit 127; fi",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "([ -f /usr/local/bin/k3s-uninstall.sh ] && /usr/local/bin/k3s-uninstall.sh) || echo >&2 '[ERROR] failed to uninstall k3s ... skip'",
    ]
  }
}

resource "null_resource" "k3s-master-updater" {
  triggers = {
    master  = null_resource.k3s-master.id
    version = local.k3s_version
  }

  connection {
    host = "${lookup(var.master_node.connection, "host", var.master_node.ip)}"

    type        = "${lookup(var.master_node.connection, "type", "ssh")}"
    user        = "${lookup(var.master_node.connection, "user", null)}"
    password    = "${lookup(var.master_node.connection, "password", null)}"
    port        = "${lookup(var.master_node.connection, "port", null)}"
    timeout     = "${lookup(var.master_node.connection, "timeout", null)}"
    script_path = "${lookup(var.master_node.connection, "script_path", null)}"

    private_key    = "${lookup(var.master_node.connection, "private_key", null)}"
    certificate    = "${lookup(var.master_node.connection, "certificate", null)}"
    agent          = "${lookup(var.master_node.connection, "agent", null)}"
    agent_identity = "${lookup(var.master_node.connection, "agent_identity", null)}"
    host_key       = "${lookup(var.master_node.connection, "host_key", null)}"

    # NOTE: Currently not working on Windows machines
    # https    = "${lookup(var.master_node.connection, "https", null)}"
    # insecure = "${lookup(var.master_node.connection, "insecure", null)}"
    # use_ntlm = "${lookup(var.master_node.connection, "use_ntlm", null)}"
    # cacert   = "${lookup(var.master_node.connection, "cacert", null)}"

    bastion_host        = "${lookup(var.master_node.connection, "bastion_host", null)}"
    bastion_host_key    = "${lookup(var.master_node.connection, "bastion_host_key", null)}"
    bastion_port        = "${lookup(var.master_node.connection, "bastion_port", null)}"
    bastion_user        = "${lookup(var.master_node.connection, "bastion_user", null)}"
    bastion_password    = "${lookup(var.master_node.connection, "bastion_password", null)}"
    bastion_private_key = "${lookup(var.master_node.connection, "bastion_private_key", null)}"
    bastion_certificate = "${lookup(var.master_node.connection, "bastion_certificate", null)}"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${local.k3s_version} sh -s - --cluster-domain ${var.cluster_name} --cluster-cidr ${var.cluster_cidr} --service-cidr ${var.cluster_service_cidr} --tls-san ${var.master_node.ip} --tls-san ${lookup(var.master_node.connection, "host", var.master_node.ip)}",
      "until kubectl get nodes | grep -v '[WARN] No resources found'; do sleep 1; done"
    ]
  }
}
