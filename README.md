terraform-module-k3s
=====================

[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module that creates a [k3s](https://k3s.io/) cluster with all node given nodes. Currently, it only applies the k3s installation script, without any settings nor HA cluster (may be in future releases).

## Usage

> This is a draft...
```
module "k3s" {
  source  = "github.com/xunleii/terraform-module-k3s"

  cluster_name = "k3s"
  master_node = {
      ip = "10.123.45.67"
      # Connection uses Terraform connection syntax
      connection = {
        user = "core"
      }
  }
  minion_nodes = [
      {
          ip = "10.123.45.68"
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "core"
          }
      },
      {
          ip = "10.123.45.69"
          connection = {
              type = "ssh"
              user = "root"
              bastion_host = "10.123.45.67"
              bastion_user = "core"
          }
      },
  ]
}
```

## License

terraform-module-k3s is released under the MIT License. See the bundled LICENSE file for details.