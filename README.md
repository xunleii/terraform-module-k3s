# terraform-module-k3s

![Terraform Version](https://img.shields.io/badge/terraform-≥_0.13-blueviolet)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/xunleii/terraform-module-k3s?label=registry)](https://registry.terraform.io/modules/xunleii/k3s)
[![GitHub issues](https://img.shields.io/github/issues/xunleii/terraform-module-k3s)](https://github.com/xunleii/terraform-module-k3s/issues)
[![Open Source Helpers](https://www.codetriage.com/xunleii/terraform-module-k3s/badges/users.svg)](https://www.codetriage.com/xunleii/terraform-module-k3s)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module which creates a [k3s](https://k3s.io/) cluster, with multi-server 
and annotations/labels/taints management features. 

## Usage

``` hcl-terraform
module "k3s" {
  source  = "xunleii/k3s/module"

  k3s_version = "v1.0.0"

  name = "my.k3s.local"
  cidr = {
    pods = "10.0.0.0/16"
    services = "10.1.0.0/16"
  }
  drain_timeout = "30s"
  managed_fields = ["label", "taint"]  

  global_flags = [
    "--tls-san k3s.my.domain.com"
  ]
  
  servers = {
    # The node name will be automatically provided by
    # the module using the field name... any usage of
    # --node-name in additional_flags will be ignored
    server_one = {
      ip = "10.123.45.67" // internal node IP
      connection = {
        host = "203.123.45.67" // public node IP
        user = "ubuntu"
      }
      flags = ["--flannel-backend=none"]

      labels = {"node.kubernetes.io/type" = "master"}
      taints = {"node.k3s.io/type" = "server:NoSchedule"}
    }
    server_two = {
      ip = "10.123.45.68"
      connection = {
        host = "203.123.45.68" // bastion node
        user = "ubuntu"
      }
      flags = ["--flannel-backend=none"]

      labels = {"node.kubernetes.io/type" = "master"}
      taints = {"node.k3s.io/type" = "server:NoSchedule"}
    }
    server_three = {
      ip = "10.123.45.69"
      connection = {
        host = "203.123.45.69" // bastion node
        user = "ubuntu"
      }
      flags = ["--flannel-backend=none"]

      labels = {"node.kubernetes.io/type" = "master"}
      taints = {"node.k3s.io/type" = "server:NoSchedule"}
    }
  }

  agents = {
      # The node name will be automatically provided by
      # the module using the field name... any usage of
      # --node-name in additional_flags will be ignored
      agent_one = {
          ip = "10.123.45.70"
          connection = {
              user = "root"
              bastion_host = "203.123.45.67" // server_one node used as bastion
              bastion_user = "ubuntu"
          }

          labels = {"node.kubernetes.io/pool" = "service-pool"}
      },
      agent_two = {
          ip = "10.123.45.71"
          connection = {
              user = "root"
              bastion_host = "203.123.45.67"
              bastion_user = "ubuntu"
          }

          labels = {"node.kubernetes.io/pool" = "service-pool"}
      },
      agent_three = {
          name = "gpu-agent-one"
          ip = "10.123.45.72"
          connection = {
              user = "root"
              bastion_host = "203.123.45.67"
              bastion_user = "ubuntu"
          }

          labels = {"node.kubernetes.io/pool" = "gpu-pool"}
          taints = {dedicated = "gpu:NoSchedule"}
      },
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| depends_on_ | Like [resource.depends_on](https://www.terraform.io/docs/configuration/resources.html#resource-dependencies), but with only one target |  |  | false |
| k3s_version | k3s version to be use | string | `"latest"` | false |
| name | k3s cluster name | string | `"cluster.local"` | false |
| cidr | k3s [CIDR definitions](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#networking) | object |  | false |
| cidr.pods | Network CIDR to use for pod IPs (`--cluster-cidr`) | string (ip) | `"10.42.0.0/16"` | false |
| cidr.service | Network CIDR to use for services IPs (`--service-cidr`) | string (ip) | `"10.43.0.0/16"` | false |
| drain_timeout | Length of time to wait before giving up the node draining | string | `"0s"` *(infinite)* | false |
| managed_fields | List of fields which must be managed by this module (can be annotation, label and/or taint) | list(string) | `["annotation", "label", "taint"]` | false |
| global_flags | Additional [installation flags](https://rancher.com/docs/k3s/latest/en/installation/install-options/) used by all nodes | list(string) | `[]` | false |
| servers | k3s server nodes definition | map([NodeType](#Node-Type)) |  | true |
| agents | k3s server nodes definition | map([NodeType](#Node-Type)) | `{}` | false |

> NOTES:  
> &nbsp;&nbsp; servers must have an odd number of nodes  
> &nbsp;&nbsp; use the first server node to configure the cluster

### Node Type

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Node name | string | `""` | false |
| ip | Node IP (used by others node to communicate) | string (ip) | | true |
| connection | Connection block used by `null_resource` to provision the node | [Connection block](https://www.terraform.io/docs/configuration/resources.html#provisioner-and-connection-resource-provisioners) | | false |
| flags | Installation flags to be used on this node | list(string) | `[]` | false |
| annotations | Map of annotations to be applied on this node (`{<name>: <value>}`) | map(string) | `{}` | false |
| labels | Map of labels to be applied on this node (`{<name>: <value>}`) | map(string) | `{}` | false |
| taints | Map of taints to be applied on this node (`{<name>: <value>}`) | map(string) | `{}` | false |

> NOTES:  
> &nbsp;&nbsp; if `name` is not specified, the key in the map will be used as name  
> &nbsp;&nbsp; **only one** taint can be applied per taint name and per node

## Outputs
| Name | Description | Type |
|------|-------------|------|
| summary | A summary of the current cluster state (version, server and agent list with all annotations, labels, ...) | string |

## More information

### Security warning

Because using external references on `destroy` provisionner is deprecated by Terraform, storing information
inside each resources will be mandatory in order to manage several features like auto-draining node 
and fields management. So, several fields like `connection` block will be available in your TF state. 
This means that used password or private key will be **clearly readable** in this TF state.  
**Please do not use
this module if you need to pass private key or password in the connection block, even if your TF state is
securely stored**.

### Kubeconfig

This module is not in charge of generating a Kubeconfig, mainly because Terraform doesn't allow us 
to get file remotely. You need to get it manually (with `external` data for example).

##### *Example:*
``` hcl-terraform
resource null_resource kubeconfig {
  provisioner "local-exec" {
    command = "scp ubuntu@203.123.45.67:/etc/rancher/k3s/k3s.yaml kubeconfig"
  }
}
```

## License

terraform-module-k3s is released under the **MIT License**. See the bundled [LICENSE](LICENSE) file for details.
