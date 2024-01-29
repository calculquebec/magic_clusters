terraform {
  required_version = ">= 1.4.0"
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=13.3.1"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "13.3.1"

  cluster_name = "paraview"
  domain       = "calculquebec.cloud"
  image        = "Rocky-8"

  instances = {
    mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p4-7.5gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "c4-30gb", tags = ["node"], count = 0 }
  }

  volumes = {
    nfs = {
      home     = { size = 100 }
      project  = { size = 100 }
      scratch  = { size = 100 }
    }
  }

  public_keys = compact(concat(split("\n", file("~/.ssh/id_rsa.pub")), ))

  nb_users = 55
  # Shared password, randomly chosen if blank
  guest_passwd = ""

  hieradata = file("./config.yaml")
}

output "accounts" {
  value = module.openstack.accounts
}

output "public_ip" {
  value = module.openstack.public_ip
}

# Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=13.3.1"
#  email            = chomp(file("../../.myemail.txt"))
  bastions         = module.openstack.bastions
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  ssh_private_key  = module.openstack.ssh_private_key
  sudoer_username  = module.openstack.accounts.sudoer.username
}

output "hostnames" {
  value = module.dns.hostnames
}
