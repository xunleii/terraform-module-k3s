data "http" "k3s_version" {
  count = var.k3s_version == "latest" ? 1 : 0
  url   = "https://api.github.com/repos/rancher/k3s/releases/latest"
}

data "http" "k3s_installer" {
  url = "https://raw.githubusercontent.com/rancher/k3s/master/install.sh" # get.k3s.io redirect to github raw installer
}

locals {
  k3s_version = var.k3s_version == "latest" ? jsondecode(data.http.k3s_version[0].body).tag_name : var.k3s_version
}
