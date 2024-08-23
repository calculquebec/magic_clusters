locals {
  name = "dat202"
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=13.3.2"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "13.3.2"

  cluster_name = local.name
  domain       = "calculquebec.cloud"
  image        = "Rocky-8"

  instances = {
    mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p4-7.5gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "p2-3.75gb", tags = ["node"], count = 55 }
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
