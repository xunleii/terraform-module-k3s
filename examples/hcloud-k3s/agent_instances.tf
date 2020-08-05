resource hcloud_server agents {
  count = var.agents_num
  name  = "k3s-agent-${count.index}"

  image       = data.hcloud_image.ubuntu.name
  server_type = "cx11-ceph"

  ssh_keys = [hcloud_ssh_key.default.id]
  labels = {
    provisioner = "terraform",
    engine      = "k3s",
    node_type   = "agent",
    nodepool    = count.index % 3 == 0 ? "gpu" : "general",
  }
}

resource hcloud_server_network agents_network {
  count     = length(hcloud_server.agents)
  server_id = hcloud_server.agents[count.index].id
  subnet_id = hcloud_network_subnet.k3s_nodes.id
  ip        = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, 1 + var.servers_num + count.index)
}
