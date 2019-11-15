resource "hcloud_ssh_key" "default" {
  name       = "K3S terraform module - Provisionning SSH key"
  public_key = var.ssh_key
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

resource "hcloud_network_subnet" "k3s_internal" {
  type         = "server"
  network_id   = hcloud_network.k3s.id
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/15"
}

data "hcloud_image" "ubuntu" {
  name = "ubuntu-18.04"
}

resource "hcloud_server" "master" {
  name = "k3s-master"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11-ceph"

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "master"
  }
}

resource "hcloud_server_network" "master_network" {
  server_id  = hcloud_server.master.id
  network_id = hcloud_network.k3s.id
  ip         = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, 1)
}

resource "hcloud_server" "minions" {
  count = var.minions_num
  name  = "k3s-minion-${count.index}"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11-ceph"

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "minion"
  }
}

resource "hcloud_server_network" "minions_network" {
  count      = length(hcloud_server.minions)
  server_id  = hcloud_server.minions[count.index].id
  network_id = hcloud_network.k3s.id
  ip         = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, count.index + 2)
}
