data "hcloud_image" "ubuntu" {
  name = "ubuntu-20.04"
}

resource "tls_private_key" "ed25519_provisioning" {
  algorithm = "ED25519"
}

resource "hcloud_ssh_key" "default" {
  name       = "K3S terraform module - Provisionning SSH key"
  public_key = trimspace(tls_private_key.ed25519_provisioning.public_key_openssh)
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

resource "hcloud_firewall" "firewall" {
  name = "firewall"

  dynamic "rule" {
    for_each = [for each in [
      {
        description = "SSH port"
        port        = 22
        source_ips = [
          "0.0.0.0/0"
        ]
      },
      {
        description = "Allow all TCP traffic on private network"
        source_ips = [
          hcloud_network.k3s.ip_range
        ]
      },
      {
        description = "Allow all UDP traffic on private network"
        source_ips = [
          hcloud_network.k3s.ip_range
        ]
        protocol = "udp"
      },
      # Direct public access only allowed if single manager node
      {
        description = "Allow access to Kubernetes API"
        port        = "6443"
        source_ips = [
          "0.0.0.0/0"
        ]
        disabled = var.servers_num > 1
      }
    ] : each if lookup(each, "disabled", false) != true]

    content {
      description     = lookup(rule.value, "description", "")
      destination_ips = lookup(rule.value, "destination_ips", [])
      direction       = lookup(rule.value, "direction", "in")
      port            = lookup(rule.value, "port", "any")
      protocol        = lookup(rule.value, "protocol", "tcp")
      source_ips      = lookup(rule.value, "source_ips", [])
    }
  }

  apply_to {
    label_selector = "provisioner=terraform"
  }
}

resource "hcloud_load_balancer" "control_plane" {
  count = var.servers_num > 1 ? 1 : 0

  name               = "load_balancer"
  load_balancer_type = "lb11"
  network_zone       = "eu-central"

  algorithm {
    type = "round_robin"
  }

  labels = {
    provisioner = "terraform",
  }
}

resource "hcloud_load_balancer_network" "control_plane" {
  count = var.servers_num > 1 ? 1 : 0

  load_balancer_id = hcloud_load_balancer.control_plane[count.index].id
  network_id       = hcloud_network.k3s.id

  depends_on = [
    hcloud_network_subnet.k3s_nodes
  ]
}
#
resource "hcloud_load_balancer_service" "kube_api" {
  count = var.servers_num > 1 ? 1 : 0

  load_balancer_id = hcloud_load_balancer.control_plane[count.index].id
  protocol         = "tcp"
  listen_port      = "6443"
  destination_port = "6443"
}

resource "hcloud_load_balancer_target" "control_plane" {
  count = var.servers_num > 1 ? 1 : 0

  load_balancer_id = hcloud_load_balancer.control_plane[count.index].id
  type             = "label_selector"
  label_selector   = join(",", [for key, value in hcloud_server.control_planes[0].labels : "${key}=${value}"])
  use_private_ip   = true

  depends_on = [
    hcloud_load_balancer_network.control_plane
  ]
}

resource "hcloud_server_network" "control_planes" {
  count     = var.servers_num
  subnet_id = hcloud_network_subnet.k3s_nodes.id
  server_id = hcloud_server.control_planes[count.index].id
}

resource "hcloud_server_network" "agents_network" {
  count     = length(hcloud_server.agents)
  server_id = hcloud_server.agents[count.index].id
  subnet_id = hcloud_network_subnet.k3s_nodes.id
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