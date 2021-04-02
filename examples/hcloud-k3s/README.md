#  K3S example for Hetzner-Cloud

Configuration in this directory creates a k3s cluster resources including network, subnet and instances.


## Usage

To run this example you need to execute:

make sure your SSH-Agent is running, and if not, start it and add your ssh-key:

```bash
# example, with active ssh-agent
ssh-add -L
ssh-rsa AAAAB4NzaC4Xc2FA2A...Me3IABDICy+WANsg5Mc= /home/user/.ssh/id_rsa
ssh-rsa AAAAB4NzaC4Xc2FA2A...VpJaZ5EawNpQaPvqEw== /home/user/.ssh/another_user_key
# if nothing is loaded
# start the ssh-agent in the background
$ eval `ssh-agent -s`
> Agent pid 59566
# add your SSH private key to the ssh-agent 
ssh-add ~./ssh/path-to-sshkey
```

then you can simply set up a k3s cluster by running
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.
