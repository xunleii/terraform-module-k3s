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

resource "hcloud_server_network" "control_planes" {
  count     = var.servers_num
  subnet_id = hcloud_network_subnet.k3s_nodes.id
  server_id = hcloud_server.control_planes[count.index].id
  ip        = cidrhost(hcloud_network_subnet.k3s_nodes.ip_range, 1 + count.index)
}
