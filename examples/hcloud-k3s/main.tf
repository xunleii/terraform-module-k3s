terraform {
  required_version = "~> 0.12.0"
}

provider "hcloud" {}

module "k3s" {
  source = "./../.."

  k3s_version          = "latest"
  cluster_cidr         = "10.0.0.0/16"
  cluster_service_cidr = "10.1.0.0/16"
  drain_timeout        = "30s"

  custom_server_args = [
    "--kube-cloud-controller-manager-arg hcloud"
  ]
  custom_agent_args = [
    "-v 10",
    "--no-flannel"
  ]

  master_node = {
    ip = hcloud_server_network.master_network.ip
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