data "civo_disk_image" "ubuntu" {
  filter {
    key      = "name"
    values   = ["ubuntu"]
    match_by = "re"
  }

  sort {
    key       = "version"
    direction = "desc"
  }
}

data "civo_instances_size" "node_size" {
  filter {
    key    = "name"
    values = ["g3.small"]
  }
}

resource "civo_instance" "node_instances" {
  count      = 3
  hostname   = "node-${count.index + 1}"
  size       = data.civo_instances_size.node_size.sizes[0].name
  disk_image = data.civo_disk_image.ubuntu[count.index].id
}
