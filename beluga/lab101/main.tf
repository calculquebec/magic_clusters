variable "TFC_WORKSPACE_NAME" { type = string }
variable "token_hieradata" {}
variable "cloud_name_hieradata" {}
variable "prometheus_password_hieradata" {}

data "tfe_workspace" "current" {
  name         = var.TFC_WORKSPACE_NAME
  organization = "CalculQuebec"
}

locals {
  hieradata = yamlencode(merge(
    var.token_hieradata,
    var.credentials_hieradata,
    var.cloud_name_hieradata,
    var.prometheus_password_hieradata,
    {
      "profile::slurm::controller::tfe_workspace" = data.tfe_workspace.current.id
    },
    {"cluster_name" = "lab101"},
    yamldecode(file("config.yaml"))
  ))
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=13.3.2"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "13.3.2"

  cluster_name = "lab101"
  domain       = "calculquebec.cloud"
  image        = "Rocky-8"

  instances = {
    mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p4-7.5gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "p2-3.75gb", tags = ["node"], count = 1, image="snapshot-cpunode-2024.1" }
    nodepoolcpu   = { type = "p2-3.75gb", tags = ["node", "pool"], count = 20, image="snapshot-cpunode-2024.1" }
  }

  # var.pool is managed by Slurm through Terraform REST API.
  # To let Slurm manage a type of nodes, add "pool" to its tag list.
  # When using Terraform CLI, this parameter is ignored.
  # Refer to Magic Castle Documentation - Enable Magic Castle Autoscaling
  pool = var.pool

  volumes = {
    nfs = {
      home     = { size = 20 }
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
