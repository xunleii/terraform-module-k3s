# terraform-module-k3s
![Terraform Version](https://img.shields.io/badge/terraform-≈_1.0-blueviolet)
[![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/xunleii/terraform-module-k3s?label=registry)](https://registry.terraform.io/modules/xunleii/k3s)
[![GitHub issues](https://img.shields.io/github/issues/xunleii/terraform-module-k3s)](https://github.com/xunleii/terraform-module-k3s/issues)
[![Open Source Helpers](https://www.codetriage.com/xunleii/terraform-module-k3s/badges/users.svg)](https://www.codetriage.com/xunleii/terraform-module-k3s)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Terraform module to create a [k3s](https://k3s.io/) cluster with multi-server and annotations/labels/taints management features.


## :warning: Security disclosure

Because the use of external references on the `destroy` provisioner is deprecated by Terraform, storing information inside each resource is mandatory in order to manage several functionalities such as automatic node draining and field management. As a result, several fields such as the `connection` block will be available in your TF state.
This means that the password or private key used will be **clearly readable** in this TF state.  
**Please be very careful to store your TF state securely if you use a private key or password in the `connection` block.**

<!-- BEGIN_TF_DOCS -->
## Example _(based on [Hetzner Cloud example](examples/hcloud-k3s))_

```hcl
module "k3s" {
  source = "xunleii/k3s/module"

  depends_on_    = hcloud_server.agents
  k3s_version    = "latest"
  cluster_domain = "cluster.local"
  cidr = {
    pods     = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
  drain_timeout  = "30s"
  managed_fields = ["label", "taint"] // ignore annotations

  global_flags = [
    "--flannel-iface ens10",
    "--kubelet-arg cloud-provider=external" // required to use https://github.com/hetznercloud/hcloud-cloud-controller-manager
  ]

  servers = {
    for i in range(length(hcloud_server.control_planes)) :
    hcloud_server.control_planes[i].name => {
      ip = hcloud_server_network.control_planes[i].ip
      connection = {
        host        = hcloud_server.control_planes[i].ipv4_address
        private_key = trimspace(tls_private_key.ed25519_provisioning.private_key_pem)
      }
      flags = [
        "--disable-cloud-controller",
        "--tls-san ${hcloud_server.control_planes[0].ipv4_address}",
      ]
      annotations = { "server_id" : i } // theses annotations will not be managed by this module
    }
  }

  agents = {
    for i in range(length(hcloud_server.agents)) :
    "${hcloud_server.agents[i].name}_node" => {
      name = hcloud_server.agents[i].name
      ip   = hcloud_server_network.agents_network[i].ip
      connection = {
        host        = hcloud_server.agents[i].ipv4_address
        private_key = trimspace(tls_private_key.ed25519_provisioning.private_key_pem)
      }

      labels = { "node.kubernetes.io/pool" = hcloud_server.agents[i].labels.nodepool }
      taints = { "dedicated" : hcloud_server.agents[i].labels.nodepool == "gpu" ? "gpu:NoSchedule" : null }
    }
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
| <a name="input_depends_on_"></a> [depends\_on\_](#input\_depends\_on\_) | Resource dependency of this module. | `any` | `null` | no |
| <a name="input_drain_timeout"></a> [drain\_timeout](#input\_drain\_timeout) | The length of time to wait before giving up the node draining. Infinite by default. | `string` | `"0s"` | no |
| <a name="input_generate_ca_certificates"></a> [generate\_ca\_certificates](#input\_generate\_ca\_certificates) | If true, this module will generate the CA certificates (see https://github.com/rancher/k3s/issues/1868#issuecomment-639690634). Otherwise rancher will generate it. This is required to generate kubeconfig | `bool` | `true` | no |
| <a name="input_global_flags"></a> [global\_flags](#input\_global\_flags) | Add additional installation flags, used by all nodes (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). | `list(string)` | `[]` | no |
| <a name="input_k3s_install_env_vars"></a> [k3s\_install\_env\_vars](#input\_k3s\_install\_env\_vars) | map of enviroment variables that are passed to the k3s installation script (see https://docs.k3s.io/reference/env-variables) | `map(string)` | `{}` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | Specify the k3s version. You can choose from the following release channels or pin the version directly | `string` | `"latest"` | no |
| <a name="input_kubernetes_certificates"></a> [kubernetes\_certificates](#input\_kubernetes\_certificates) | A list of maps of cerificate-name.[crt/key] : cerficate-value to copied to /var/lib/rancher/k3s/server/tls, if this option is used generate\_ca\_certificates will be treat as false | <pre>list(<br>    object({<br>      file_name    = string,<br>      file_content = string<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_managed_fields"></a> [managed\_fields](#input\_managed\_fields) | List of fields which must be managed by this module (can be annotation, label and/or taint). | `list(string)` | <pre>[<br>  "annotation",<br>  "label",<br>  "taint"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | K3s cluster domain name (see https://rancher.com/docs/k3s/latest/en/installation/install-options/). This input is deprecated and will be remove in the next major release. Use `cluster_domain` instead. | `string` | `"!!!DEPRECATED!!!"` | no |
| <a name="input_separator"></a> [separator](#input\_separator) | Separator used to separates node name and field name (used to manage annotations, labels and taints). | `string` | `"\|"` | no |
| <a name="input_use_sudo"></a> [use\_sudo](#input\_use\_sudo) | Whether or not to use kubectl with sudo during cluster setup. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Genereated kubeconfig. |
| <a name="output_kubernetes"></a> [kubernetes](#output\_kubernetes) | Authentication credentials of Kubernetes (full administrator). |
| <a name="output_kubernetes_cluster_secret"></a> [kubernetes\_cluster\_secret](#output\_kubernetes\_cluster\_secret) | Secret token used to join nodes to the cluster |
| <a name="output_kubernetes_ready"></a> [kubernetes\_ready](#output\_kubernetes\_ready) | Dependency endpoint to synchronize k3s installation and provisioning. |
| <a name="output_summary"></a> [summary](#output\_summary) | Current state of k3s (version & nodes). |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | ~> 4.0 |
<!-- END_TF_DOCS -->

## Frequently Asked Questions

### How to customise the generated `kubeconfig`

It is sometimes necessary to modify the context or the cluster name to adapt `kubeconfig` to a third-party tool or to avoid conflicts with existing tools. Although this is not the role of this module, it can easily be done with its outputs :

```hcl
module "k3s" {
  ...
}

local {
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "my-context-name"
    contexts = [{
      context = {
        cluster = "my-cluster-name"
        user : "my-user-name"
      }
      name = "my-context-name"
    }]
    clusters = [{
      cluster = {
        certificate-authority-data = base64encode(module.k3s.kubernetes.cluster_ca_certificate)
        server                     = module.k3s.kubernetes.api_endpoint
      }
      name = "my-cluster-name"
    }]
    users = [{
      user = {
        client-certificate-data : base64encode(module.k3s.kubernetes.client_certificate)
        client-key-data : base64encode(module.k3s.kubernetes.client_key)
      }
      name : "my-user-name"
    }]
  })
}
```

## License
`terraform-module-k3s` is released under the **MIT License**. See the bundled [LICENSE](LICENSE) file for details.

#
*Generated with :heart: by [terraform-docs](https://github.com/terraform-docs/terraform-docs)*
