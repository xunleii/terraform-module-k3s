// Fetch the last version of k3s
data "http" "k3s_version" {
  url = "https://api.github.com/repos/rancher/k3s/releases/latest"
}

// Fetch the k3s installation script
data "http" "k3s_installer" {
  url = "https://raw.githubusercontent.com/rancher/k3s/${jsondecode(data.http.k3s_version.body).tag_name}/install.sh"
}

locals {
  // Use the fetched version if 'lastest' is specified
  k3s_version = var.k3s_version == "latest" ? jsondecode(data.http.k3s_version.body).tag_name : var.k3s_version
}
