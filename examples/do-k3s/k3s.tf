module "k3s" {
  source = "./../.."

  depends_on_    = digitalocean_droplet.node_instances
  k3s_version    = "latest"
  cluster_domain = "do_k3s"

  drain_timeout            = "60s"
  managed_fields           = ["label"]
  generate_ca_certificates = true

  global_flags = [for instance in digitalocean_droplet.node_instances : "--tls-san ${instance.ipv4_address}"]

  servers = {
    # The node name will be automatically provided by
    # the module using the field name... any usage of
    # --node-name in additional_flags will be ignored

    for instance in digitalocean_droplet.node_instances :
    instance.name => {
      ip = instance.ipv4_address_private
      connection = {
        timeout     = "60s"
        type        = "ssh"
        host        = instance.ipv4_address
        private_key = trimspace(tls_private_key.ed25519_provisioning.private_key_pem)
      }

      labels = { "node.kubernetes.io/type" = "master" }
    }
  }
}
