data "digitalocean_image" "ubuntu" {
  slug = "ubuntu-22-04-x64"
}

resource "tls_private_key" "ed25519_provisioning" {
  algorithm = "ED25519"
}

resource "digitalocean_ssh_key" "default" {
  name       = "K3S terraform module - Provisionning SSH key"
  public_key = trimspace(tls_private_key.ed25519_provisioning.public_key_openssh)
}

resource "digitalocean_droplet" "node_instances" {
  count = 3

  image    = data.digitalocean_image.ubuntu.slug
  name     = "k3s-node-${count.index}"
  region   = "ams3"
  size     = "s-1vcpu-2gb"
  ssh_keys = [digitalocean_ssh_key.default.fingerprint]
}
