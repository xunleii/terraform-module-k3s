resource hcloud_ssh_key default {
  name       = "K3S terraform module - Provisionning SSH key"
  public_key = var.ssh_key
}

resource hcloud_network k3s {
  name     = "k3s-network"
  ip_range = "10.0.0.0/8"
}

resource hcloud_network_subnet k3s_nodes {
  type         = "server"
  network_id   = hcloud_network.k3s.id
  network_zone = "eu-central"
  ip_range     = "10.254.1.0/24"
}

data hcloud_image ubuntu {
  name = "ubuntu-18.04"
}

resource hcloud_server server {
  name = "k3s-server"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11-ceph"

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "server"
  }
}

resource hcloud_server_network server_network {
  server_id  = hcloud_server.server.id
  network_id = hcloud_network.k3s.id
  ip         = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, 1)
}

resource hcloud_server agents {
  count = var.agents_num
  name  = "k3s-agent-${count.index}"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11-ceph"

  ssh_keys = [
    hcloud_ssh_key.default.id
  ]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "agent"
  }
}

resource hcloud_server_network agents_network {
  count      = length(hcloud_server.agents)
  server_id  = hcloud_server.agents[count.index].id
  network_id = hcloud_network.k3s.id
  ip         = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, count.index + 2)
}
