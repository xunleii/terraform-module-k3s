terraform {
  required_providers {
    civo = {
      source  = "civo/civo"
      version = "0.9.21"
    }
  }
}

provider "civo" {
  token = var.civo_token
}

variable civo_token {
  type        = string
  description = "Civo api token"
}

data "civo_template" "ubuntu" {
  filter {
    key    = "code"
    values = ["ubuntu-18.04"]
  }
}

data "civo_instances_size" "node_size" {
  filter {
    key    = "name"
    values = ["g2.small"]
  }
}

resource "civo_instance" "node_instances" {
  count    = 3
  hostname = "node-${count.index + 1}"
  size     = element(data.civo_instances_size.node_size.sizes, 0).name
  template = element(data.civo_template.ubuntu.templates, 0).id
}

module k3s {
  source      = "./../.."
  k3s_version = "v1.19.2+k3s1"

  name = "civo_k3s"

  drain_timeout  = "60s"
  managed_fields = ["label"]
  generate_ca_certificates = true

  global_flags = [for instance in civo_instance.node_instances : "--tls-san ${instance.public_ip}"]

  servers = {
    # The node name will be automatically provided by
    # the module using the field name... any usage of
    # --node-name in additional_flags will be ignored

    for instance in civo_instance.node_instances :
    instance.hostname => {
      ip = instance.private_ip
      connection = {
        timeout  = "60"
        type     = "ssh"
        host     = instance.public_ip
        password = instance.initial_password
        user     = "root"
      }

      labels = { "node.kubernetes.io/type" = "master" }
    }
  }
}

output "kube_config" {
  value = module.k3s.kube_config
}