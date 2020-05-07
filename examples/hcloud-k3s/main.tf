provider hcloud {}

module k3s {
  source = "./../.."

  k3s_version = "latest"
  cluster_cidr = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
  drain_timeout = "30s"

  server_node = {
    name   = "server"
    ip     = hcloud_server_network.server_network.ip
    labels = {}
    taints = {}
    connection = {
      host = hcloud_server.server.ipv4_address
    }
    additional_flags = [
      "--disable-cloud-controller",
      "--flannel-iface ens10",
      "--kubelet-arg cloud-provider=external",                           # required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
      "--kubelet-arg provider-id=hcloud://${hcloud_server.server.id}"
    ]
  }

  agent_nodes = {
    for i in range(length(hcloud_server.agents)) :
    "${hcloud_server.agents[i].name}_node" => {
      name = "${hcloud_server.agents[i].name}"
      ip   = hcloud_server_network.agents_network[i].ip

      labels = {
        "node.kubernetes.io/pool" = hcloud_server.agents[i].labels.nodepool
      }
      taints = {
        "dedicated" : hcloud_server.agents[i].labels.nodepool == "gpu" ? "gpu:NoSchedule" : null
      }

      connection = {
        host = hcloud_server.agents[i].ipv4_address
      }

      additional_flags = [
        "--flannel-iface ens10",
        "--kubelet-arg cloud-provider=external",                         # required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
        "--kubelet-arg provider-id=hcloud://${hcloud_server.agents[i].id}"
      ]
    }
  }
}
