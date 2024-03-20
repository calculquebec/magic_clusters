locals {
  name = "cip201"
  custom_pod = {
  	scratch_size = 20
	ncpu = 1
	ncpupool = 8
	ngpu = 1
	ngpupool = 10
  }
  custom = {
	instances = {
	  mgmt   = local.default.instances_map[var.cloud_name]["mgmt"]
	  login  = local.default.instances_map[var.cloud_name]["login"]
	  node   = { type = "c8-60gb-186", tags = ["node"], count = 2 }
	  compute-node   = local.default.instances_map[var.cloud_name]["cpu-node"]
	  compute-nodepool   = local.default.instances_map[var.cloud_name]["cpu-nodepool"]
	  gpu-node   = local.default.instances_map[var.cloud_name]["gpu-node"]
	  gpu-nodepool   = local.default.instances_map[var.cloud_name]["gpu-nodepool"]
	}
  }
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=13.3.2"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
  config_version = "13.3.2"

  cluster_name = local.name
  domain       = "calculquebec.cloud"
  image        = "Rocky-8"

  instances = local.instances

  # var.pool is managed by Slurm through Terraform REST API.
  # To let Slurm manage a type of nodes, add "pool" to its tag list.
  # When using Terraform CLI, this parameter is ignored.
  # Refer to Magic Castle Documentation - Enable Magic Castle Autoscaling
  pool = var.pool

  volumes = local.volumes

  generate_ssh_key = true
  public_keys = compact(concat(split("\n", file("../../sshkeys.pub")), ))

  nb_users = 55
  # Shared password, randomly chosen if blank
  guest_passwd = ""

  hieradata = local.hieradata
}

