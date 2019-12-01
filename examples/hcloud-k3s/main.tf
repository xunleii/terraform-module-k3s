provider hcloud {}

module k3s {
  source = "./../.."

  k3s_version = "latest"
  cluster_cidr = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
  drain_timeout = "30s"

  additional_flags = {
    master = [
      "--disable-cloud-controller",
      "--flannel-iface ens10",
      "--kubelet-arg cloud-provider=external" # required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
    ]
    minion = [
      "--flannel-iface ens10",
      "--kubelet-arg cloud-provider=external" # required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
    ]
  }

  master_node = {
    name = "master"
    ip   = hcloud_server_network.master_network.ip
    connection = {
      host = hcloud_server.master.ipv4_address
    }
  }

  minion_nodes = {
    for i in range(length(hcloud_server.minions)) :
    hcloud_server.minions[i].name => {
      ip = hcloud_server_network.minions_network[i].ip
      connection = {
        host = hcloud_server.minions[i].ipv4_address
      }
    }
  }
}