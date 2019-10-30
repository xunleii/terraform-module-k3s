resource "null_resource" "k3s-master" {
  triggers = {
    cluster_settings = "${sha256(join("", [var.cluster_name, var.cluster_name, var.cluster_name]))}"
    master = "${var.master_node.ip}"
    now = "${timestamp()}"
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

    https    = "${lookup(var.master_node.connection, "https", null)}"
    insecure = "${lookup(var.master_node.connection, "insecure", null)}"
    use_ntlm = "${lookup(var.master_node.connection, "use_ntlm", null)}"
    cacert   = "${lookup(var.master_node.connection, "cacert", null)}"

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
      "command -V curl > /dev/null || (echo >&2 'curl must be installed to continue...' && exit 127)",
      "curl -sfL https://get.k3s.io | sh -s - --cluster-domain ${var.cluster_name} --cluster-cidr ${var.cluster_cidr} --service-cidr ${var.cluster_service_cidr}",
      "until kubectl get nodes | grep -v 'No resources found'; do sleep 1; done"
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "/usr/local/bin/k3s-uninstall.sh",
    ]
  }
}