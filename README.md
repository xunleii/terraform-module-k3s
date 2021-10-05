# terraform-module-k3s
![Terraform Version](https://img.shields.io/badge/terraform-≈_1.0-blueviolet)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/xunleii/terraform-module-k3s?label=registry)](https://registry.terraform.io/modules/xunleii/k3s)
[![GitHub issues](https://img.shields.io/github/issues/xunleii/terraform-module-k3s)](https://github.com/xunleii/terraform-module-k3s/issues)
[![Open Source Helpers](https://www.codetriage.com/xunleii/terraform-module-k3s/badges/users.svg)](https://www.codetriage.com/xunleii/terraform-module-k3s)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module which creates a [k3s](https://k3s.io/) cluster, with multi-server
and annotations/labels/taints management features.

## Usage
``` hcl
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
    server-one = {
      ip = "10.123.45.67" // internal node IP
      connection = {
        host = "203.123.45.67" // public node IP
        user = "ubuntu"
      }
      flags = ["--flannel-backend=none"]
      labels = {"node.kubernetes.io/type" = "master"}
      taints = {"node.k3s.io/type" = "server:NoSchedule"}
    }
    server-two = {
      ip = "10.123.45.68"
      connection = {
        host = "203.123.45.68" // bastion node
        user = "ubuntu"
      }
      flags = ["--flannel-backend=none"]
      labels = {"node.kubernetes.io/type" = "master"}
      taints = {"node.k3s.io/type" = "server:NoSchedule"}
    }
    server-three = {
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
      agent-one = {
          ip = "10.123.45.70"
          connection = {
              user = "root"
              bastion_host = "203.123.45.67" // server_one node used as bastion
              bastion_user = "ubuntu"
          }
          labels = {"node.kubernetes.io/pool" = "service-pool"}
      },
      agent-two = {
          ip = "10.123.45.71"
          connection = {
              user = "root"
              bastion_host = "203.123.45.67"
              bastion_user = "ubuntu"
          }
          labels = {"node.kubernetes.io/pool" = "service-pool"}
      },
      agent-three = {
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
|------|-------------|------|---------|:--------:|
| <a name="input_servers"></a> [servers](#input\_servers) | K3s server nodes definition. The key is used as node name if no name is provided. | `map(any)` | n/a | yes |
| <a name="input_agents"></a> [agents](#input\_agents) | K3s agent nodes definitions. The key is used as node name if no name is provided. | `map(any)` | `{}` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | K3s network CIDRs (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). | <pre>object({<br>    pods     = string<br>    services = string<br>  })</pre> | <pre>{<br>  "pods": "10.42.0.0/16",<br>  "services": "10.43.0.0/16"<br>}</pre> | no |
| <a name="input_cluster_domain"></a> [cluster\_domain](#input\_cluster\_domain) | K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). | `string` | `"cluster.local"` | no |
| <a name="input_depends_on_"></a> [depends\_on\_](#input\_depends\_on\_) | Resouce dependency of this module. | `any` | `null` | no |
| <a name="input_drain_timeout"></a> [drain\_timeout](#input\_drain\_timeout) | The length of time to wait before giving up the node draining. Infinite by default. | `string` | `"0s"` | no |
| <a name="input_generate_ca_certificates"></a> [generate\_ca\_certificates](#input\_generate\_ca\_certificates) | If true, this module will generate the CA certificates (see https://github.com/rancher/k3s/issues/1868#issuecomment-639690634). Otherwise rancher will generate it. This is required to generate kubeconfig | `bool` | `true` | no |
| <a name="input_global_flags"></a> [global\_flags](#input\_global\_flags) | Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). | `list(string)` | `[]` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | Specify the k3s version. You can choose from the following release channels or pin the version directly | `string` | `"latest"` | no |
| <a name="input_kubernetes_certificates"></a> [kubernetes\_certificates](#input\_kubernetes\_certificates) | A list of maps of cerificate-name.[crt/key] : cerficate-value to copied to /var/lib/rancher/k3s/server/tls, if this option is used generate\_ca\_certificates will be treat as false | <pre>list(<br>    object({<br>      file_name    = string,<br>      file_content = string<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_managed_fields"></a> [managed\_fields](#input\_managed\_fields) | List of fields which must be managed by this module (can be annotation, label and/or taint). | `list(string)` | <pre>[<br>  "annotation",<br>  "label",<br>  "taint"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). This input is deprecated and will be remove in the next major release. Use `cluster_domain` instead. | `string` | `"cluster.local"` | no |
| <a name="input_separator"></a> [separator](#input\_separator) | Separator used to separates node name and field name (used to manage annotations, labels and taints). | `string` | `"|"` | no |
| <a name="input_use_sudo"></a> [use_sudo](#input\_use\_sudo) | Whether or not to use kubectl with sudo during cluster setup. | `bool` | `false` | no |

> NOTES: <br/>
> &nbsp;&nbsp; servers must have an odd number of nodes <br/>
> &nbsp;&nbsp; use the first server node to configure the cluster <br/>
> &nbsp;&nbsp; if `name` is not specified, the key in the map will be used as name <br/>
> &nbsp;&nbsp; **only one** taint can be applied per taint name and per node <br/>


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Genereated kubeconfig. |
| <a name="output_kubernetes"></a> [kubernetes](#output\_kubernetes) | Authentication credentials of Kubernetes (full administrator). |
| <a name="output_kubernetes_ready"></a> [kubernetes\_ready](#output\_kubernetes\_ready) | Dependency endpoint to synchronize k3s installation and provisioning. |
| <a name="output_summary"></a> [summary](#output\_summary) | Current state of k3s (version & nodes). |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 1.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 2.2 |

## Security warning
Because using external references on `destroy` provisionner is deprecated by Terraform, storing information
inside each resources will be mandatory in order to manage several features like auto-draining node
and fields management. So, several fields like `connection` block will be available in your TF state.
This means that used password or private key will be **clearly readable** in this TF state.
**Please do not use
this module if you need to pass private key or password in the connection block, even if your TF state is
securely stored**.

## License
terraform-module-k3s is released under the **MIT License**. See the bundled [LICENSE](LICENSE) file for details.

#
*Generated with :heart: by [terraform-docs](https://github.com/terraform-docs/terraform-docs)*

