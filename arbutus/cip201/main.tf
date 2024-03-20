locals {
  name = 'cip201'
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=13.3.2"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "13.3.2"

  cluster_name = local.name
  domain       = "calculquebec.cloud"
  image        = "Rocky-8"

  instances = {
    mgmt   = { type = "p8-12gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    login  = { type = "p4-6gb", tags = ["login", "public", "proxy"], count = 1 }
    node   = { type = "c8-60gb-186", tags = ["node"], count = 2 }
    compute-node   = { type = "c8-60gb-186", tags = ["node"], count = 1 }
    compute-nodepool   = { type = "c8-60gb-186", tags = ["node", "pool"], count = 8, image="snapshot-cpunode-2024.1" }
    gpu-node   = { type = "g1-8gb-c4-22gb", tags = ["node"], count = 1 }
    gpu-nodepool   = { type = "g1-8gb-c4-22gb", tags = ["node", "pool"], count = 10, image="snapshot-gpunode-2024.1" }
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

