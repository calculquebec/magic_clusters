terraform {
  required_version = ">= 1.4.0"
}

variable "pool" {
  description = "Slurm pool of compute nodes"
  default = []
}
variable "token_hieradata" {}
variable "credentials_hieradata" { default= "" }
variable "cloud_name_hieradata" { default="" }
variable "prometheus_password_hieradata" { default="" }
variable "TFC_WORKSPACE_NAME" { type = string }

data "tfe_workspace" "current" {
  name         = var.TFC_WORKSPACE_NAME
  organization = "CalculQuebec"
}

locals {
  hieradata = yamlencode(merge(
    var.credentials_hieradata,
    var.cloud_name_hieradata,
    var.prometheus_password_hieradata,
    var.token_hieradata,
    {"profile::slurm::controller::tfe_workspace" = data.tfe_workspace.current.id},
    {"cluster_name" = "cgpu101"},
     yamldecode(file("config.yaml"))
  ))
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=13.3.2"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "13.3.2"

  cluster_name = "cgpu101"
  domain       = "calculquebec.cloud"
  image        = "Rocky-8"

  instances = {
    mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p4-6gb", tags = ["login", "public", "proxy"], count = 1 }
    gpu-node   = { type = "g1-8gb-c4-22gb", tags = ["node"], count = 1 }
    gpu-nodepool   = { type = "g1-8gb-c4-22gb", tags = ["node", "pool"], count = 40, image="snapshot-gpunode-2024.1" }
  }

  # var.pool is managed by Slurm through Terraform REST API.
  # To let Slurm manage a type of nodes, add "pool" to its tag list.
  # When using Terraform CLI, this parameter is ignored.
  # Refer to Magic Castle Documentation - Enable Magic Castle Autoscaling
  pool = var.pool

  volumes = {
    nfs = {
      home     = { size = 200 }
      project  = { size = 20 }
      scratch  = { size = 20 }
    }
  }

  generate_ssh_key = true
  public_keys = compact(concat(split("\n", file("../../sshkeys.pub")), ))

  nb_users = 55
  # Shared password, randomly chosen if blank
  guest_passwd = ""

  hieradata = local.hieradata
}

output "accounts" {
  value = module.openstack.accounts
}

output "public_ip" {
  value = module.openstack.public_ip
}

# Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=13.3.2"
#  email            = chomp(file("../../.myemail.txt"))
  bastions         = module.openstack.bastions
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
