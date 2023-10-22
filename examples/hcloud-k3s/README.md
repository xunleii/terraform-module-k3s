#  K3S example for Hetzner-Cloud

Configuration in this directory creates a k3s cluster resources including network, subnet and instances.

## Usage

> [!warning]
> **Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.**

```bash
$ export HCLOUD_TOKEN=...
$ terraform init
$ terraform apply
```

## How to connect to a node ?

```bash
terraform output -raw ssh_private_key | ssh-add -
ssh root@NODE-IP
```
