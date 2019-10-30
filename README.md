# terraform-module-k3s

[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module that creates a [k3s](https://k3s.io/) cluster with all node given nodes. Currently, it only applies the k3s installation script, without any complex settings nor HA cluster (may be in future releases).

## Usage

``` terraform
module "k3s" {
  source  = "xunleii/k3s/module"

  k3s_version = "v0.10.2"

  cluster_name = "my.k3s.local"
  cluster_cidr = "10.0.0.0/16"
  cluster_service_cidr = "10.1.0.0/16"
  additional_tls_san = ["k3s.my.domain.com"]
  
  master_node = {
      # This IP will be used as k3s master node IP.... if you want to use a public
      # address for the connection, use connection.host instead
      ip = "10.123.45.67"

      # Connection uses Terraform connection syntax
      connection = {
        host = "203.123.45.67"
        user = "ubuntu"
      }
  }
  minion_nodes = [
      {
          ip = "10.123.45.68"
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "ubuntu"
          }
      },
      {
          ip = "10.123.45.69"
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "ubuntu"
          }
      },
  ]
}
```

## License

terraform-module-k3s is released under the MIT License. See the bundled LICENSE file for details.
