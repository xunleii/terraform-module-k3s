provider "hcloud" {}

data "hcloud_image" "ubuntu" {
  name = "ubuntu-20.04"
}

resource "tls_private_key" "ed25519-provisioning" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "default" {
  name       = "K3S terraform module - Provisionning SSH key"
  public_key = trimspace(tls_private_key.ed25519-provisioning.public_key_openssh)
}

resource "hcloud_network" "k3s" {
  name     = "k3s-network"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "k3s_nodes" {
  type         = "server"
  network_id   = hcloud_network.k3s.id
  network_zone = "eu-central"
  ip_range     = "10.254.1.0/24"
}
