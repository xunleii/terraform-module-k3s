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

resource "hcloud_server_network" "control_planes" {
  count     = var.servers_num
  subnet_id = hcloud_network_subnet.k3s_nodes.id
  server_id = hcloud_server.control_planes[count.index].id
  ip        = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, 1 + count.index)
}

resource "hcloud_server_network" "agents_network" {
  count     = length(hcloud_server.agents)
  server_id = hcloud_server.agents[count.index].id
  subnet_id = hcloud_network_subnet.k3s_nodes.id
  ip        = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, 1 + var.servers_num + count.index)
}

resource "hcloud_server" "control_planes" {
  count = var.servers_num
  name  = "k3s-control-plane-${count.index}"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11"

  ssh_keys = [hcloud_ssh_key.default.id]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "control-plane"
  }
}


resource "hcloud_server" "agents" {
  count = var.agents_num
  name  = "k3s-agent-${count.index}"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11"

  ssh_keys = [hcloud_ssh_key.default.id]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "agent",
    nodepool    = count.index % 3 == 0 ? "gpu" : "general",
  }
}