data "http" "k3s_version" {
  url = "https://api.github.com/repos/rancher/k3s/releases/latest"
}

locals {
  k3s_version = "${var.k3s_version == "latest" ? "${jsondecode(data.http.k3s_version.body).tag_name}" : var.k3s_version}"
}
