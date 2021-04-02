#  K3S example for Hetzner-Cloud

Configuration in this directory creates a k3s cluster resources including network, subnet and instances.

## Preparations

Make sure your [SSH-Agent](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent) is running (it is neccessary for Terraform), and if not, start it and add your ssh-key:

```bash
# example, with active ssh-agent
$ ssh-add -L
> ssh-rsa AAAAB4NzaC4Xc2FA2A...Me3IABDICy+WANsg5Mc= /home/user/.ssh/id_rsa
> ssh-rsa AAAAB4NzaC4Xc2FA2A...VpJaZ5EawNpQaPvqEw== /home/user/.ssh/another_user_key
# if nothing is loaded
# start the ssh-agent in the background
$ eval `ssh-agent -s`
> Agent pid 59566
# add your SSH private key to the ssh-agent
$ ssh-add ~./ssh/path-to-sshkey
> Identity added: ~./ssh/path-to-sshkey (~./ssh/path-to-sshkey)
```

## Usage

After checking/enabling ssh-agent, to run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.
