terraform {
  required_version = ">= 1.2.1"
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=12.3.0"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "12.3.0"

  cluster_name = "dat201"
  domain       = "calculquebec.cloud"
  image        = "Rocky-8.6-x64-2022-07"

  instances = {
    mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p4-6gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "c16-180gb-392", tags = ["node"], count = 1 }
  }

  volumes = {
    nfs = {
      home     = { size = 20 }
      project  = { size = 20 }
      scratch  = { size = 20 }
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
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=12.3.0"
  email            = "YOUR EMAIL"
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  ssh_private_key  = module.openstack.ssh_private_key
  sudoer_username  = module.openstack.accounts.sudoer.username
}

## Uncomment to register your domain name with Google Cloud
# module "dns" {
#   source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/gcloud"
#   email            = "you@example.com"
#   project          = "your-project-id"
#   zone_name        = "you-zone-name"
#   name             = module.openstack.cluster_name
#   domain           = module.openstack.domain
#   public_instances = module.openstack.public_instances
#   ssh_private_key  = module.openstack.ssh_private_key
#   sudoer_username  = module.openstack.accounts.sudoer.username
# }

output "hostnames" {
  value = module.dns.hostnames
}
