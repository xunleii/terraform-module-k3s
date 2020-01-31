# terraform-module-k3s

[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module that creates a [k3s](https://k3s.io/) cluster with all node given nodes. Currently, it only applies the k3s installation script. HA clustering is not managed.  
> :warning: **This module only works with k3s version greater than v1.0.0**

## Usage

``` hcl-terraform
module "k3s" {
  source  = "xunleii/k3s/module"

  k3s_version = "v1.0.0"

  cluster_name = "my.k3s.local"
  cluster_cidr = {
    pods = "10.0.0.0/16"
    services = "10.1.0.0/16"
  }

  additional_flags = {
    server = [
        "--flannel-backend=none",
        "--tls-san k3s.my.domain.com"
    ]
    agent = [
      "--flannel-backend=none",
    ]
  }
  
  server_node = {
      # The node name will be automatically provided by 
      # the module using this value... any usage of --node-name
      # in additional_flags will be ignored
      name = "master"
  
      # This IP will be used as k3s master node IP.... if you want to use a public
      # address for the connection, use connection.host instead
      ip = "10.123.45.67"

      # The node labels & taints can be set using theses fields
      labels = {
        "node.kubernetes.io/type" = "master"
      }
      taints = {
        "node.k3s.io/type" = "server:NoSchedule"
      }

      # Connection uses Terraform connection syntax
      connection = {
        host = "203.123.45.67"
        user = "ubuntu"
      }
  }
  agent_nodes = {
      # The node name will be automatically provided by 
      # the module using the key... any usage of --node-name
      # in additional_flags will be ignored
      k3s-node-01 = {
          ip = "10.123.45.68"
          labels = {
            "node.kubernetes.io/pool" = "service-pool"
          }
          taints = {}
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "ubuntu"
          }
      },
      k3s-node-02 = {
          ip = "10.123.45.69"
          labels = {
            "node.kubernetes.io/pool" = "service-pool"
          }
          taints = {}
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "ubuntu"
          }
      },
      k3s-node-03 = {
          ip = "10.123.45.70"
          labels = {
            "node.kubernetes.io/pool" = "monitoring-pool"
          }
          taints = {
            dedicated = "monitoring:NoSchedule"
          }
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "ubuntu"
          }
      },
  }
}
```

### Connection

The `connection` object can use all [Terraform connection arguments](https://www.terraform.io/docs/provisioners/connection.html#argument-reference).

### Kubeconfig

Because Terraform doesn't allow us to get file remotely, you need to get it manually (with `external` data for example).

``` hcl-terraform
resource null_resource kubeconfig {
  provisioner "local-exec" {
    command = "scp ubuntu@203.123.45.67:/etc/rancher/k3s/k3s.yaml kubeconfig"
  }
}
```

## License

terraform-module-k3s is released under the MIT License. See the bundled LICENSE file for details.
