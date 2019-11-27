locals {
  # Generates the master public IP address
  master_host = lookup(var.master_node.connection, "host", var.master_node.ip)

  # Generates custom TLS Subject Alternative Name for the cluster
  tls_san_values = distinct(
    concat(
      [var.master_node.ip, local.master_host],
      var.additional_tls_san
    )
  )
  tls_san_opts = "--tls-san ${join(" --tls-san ", local.tls_san_values)}"

  # Generates the master installation arguments
  master_install_arg_list = concat(
    [
      "--node-ip ${var.master_node.ip}",
      "--cluster-domain ${var.cluster_name}",
      "--cluster-cidr ${var.cluster_cidr}",
      "--service-cidr ${var.cluster_service_cidr}",
      local.tls_san_opts,
    ],
    var.custom_server_args,
    var.custom_agent_args
  )
  master_install_args = join(" ", local.master_install_arg_list)

  # Generates the master installation env vars
  master_install_env_list = [
    "INSTALL_K3S_VERSION=${local.k3s_version}",
    "K3S_CLUSTER_SECRET=${random_password.k3s_cluster_secret.result}"
  ]
  master_install_envs = join(" ", local.master_install_env_list)
}

resource "null_resource" "k3s_master" {
  triggers = {
    master_ip    = sha1(var.master_node.ip)
    install_args = sha1(local.master_install_args)
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

  # Check if curl is installed
  provisioner "remote-exec" {
    inline = [
      "if ! command -V curl > /dev/null; then echo >&2 '[ERROR] curl must be installed to continue...'; exit 127; fi",
    ]
  }

  # Remove old k3s installation
  provisioner "remote-exec" {
    inline = [
      "if ! command -V k3s-uninstall.sh > /dev/null; then exit; fi",
      "echo >&2 [WARN] K3S seems already installed on this node and will be uninstalled.",
      "k3s-uninstall.sh",
    ]
  }
}

resource "null_resource" "k3s_master_installer" {
  triggers = {
    master_init = null_resource.k3s_master.id
    version     = local.k3s_version
  }
  depends_on = [null_resource.k3s_master]

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

  # Install K3S server
  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | ${local.master_install_envs} sh -s - ${local.master_install_args}",
      "until kubectl get nodes | grep -v '[WARN] No resources found'; do sleep 1; done"
    ]
  }
}
