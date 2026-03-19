terraform {
  required_version = ">= 1.4.0"
}
variable "pool" {
  description = "Slurm pool of compute nodes"
  default = []
}
variable "TFC_WORKSPACE_NAME" {
  type = string
  default = ""
}
variable "tfe_token" {
  type = string
  default = ""
}
variable "cloud_name" {
  type = string
  default = ""
}
variable "eyaml_key" { }
variable "prometheus_password" {
  type = string
  default = ""
}
variable "google_calendar_id" {
  type = string
  default = ""
}
variable "google_api_key" {
  type = string
  default = ""
}
variable "credentials_hieradata" { default= {} }
variable "suffix" {
  type = string
  default = ""
}
variable "os_ext_network" {
  type = string
  default = ""
}
variable "subnet_id" {
  type = string
  default = ""
}
data "tfe_workspace" "current" {
  name         = var.TFC_WORKSPACE_NAME
  organization = "CalculQuebec"
}

locals {
  default_pod = {
    image = "AlmaLinux-9"
    image_compute = "snapshot-cpunode-2025.3-A9.6"
    image_map = {
      gpu = "snapshot-gpunode-2025.3-A9.6"
      gpupool = "snapshot-gpunode-2025.3-A9.6"
    }
    nb_users = 0

    nnodes = {
      cpu = 2
      login = 1
    }
    
    features = {
      gpu = ["gpu"],
      gpupool = ["gpu"],
    }

    home_size = 80
    project_size = 20
    scratch_size = 20

    user_quotas_sizes = {
      home = "1g"
      project = "1g"
      scratch = "1g"
    }
    user_quotas_inodes = {
      home = 100000
      project = 100000
      scratch = 100000
    }

    cluster_purpose = "formation"
    config_git_url = "https://github.com/calculquebec/puppet-magic_castle_formation.git"
    config_version = "e2d4f36"

    node_flavors = {
      arbutus = ["cpu", "compute-node", "cpupool", "gpu", "gpupool"],
      beluga = ["cpu", "compute-node", "cpupool"]
      juno = ["cpu", "cpupool", "gpu", "gpupool"]
    }
    tags = {
      cpu = ["node"]
      gpu = ["node"]
    }
    instances_type_map = {
      arbutus = {
        mgmt = "p8-12gb"
        login = "p4-6gb"
        jupyter = "p4-6gb"
        cpu = "c8-30gb-186-avx2"
        cpupool = "c8-30gb-186-avx2"
        compute-node = "p8-12gb"
        gpu = "g1-8gb-c4-22gb"
        gpupool = "g1-8gb-c4-22gb"
      }
      beluga = {
        mgmt = "p4-7.5gb"
        login = "p4-7.5gb"
        jupyter = "p4-7.5gb"
        cpu = "c8-60gb"
        cpupool = "c8-60gb"
        compute-node = "p8-15gb"
      }
      juno = {
        mgmt = "ha4-15gb"
        login = "ha4-15gb"
        jupyter = "c4-15gb"
        cpu = "c8-30gb"
        cpupool = "c8-30gb"
	gpu = "gpu16-240-3450gb-a100x1_cq"
        gpupool = "gpu12-120-850gb-a100x1_MC"
      }
    }

    disk_size = {
      gpu = 50
      gpupool = 50
    }
    
    mig = {
      gpu = { "1g.5gb" = 7 }
      gpupool = { "1g.5gb" = 7 }
    }

    shard = {
      gpu = null
      gpupool = null
    }
  }

  user_quotas = {
    home = {
      bsoft = try(local.custom.user_quotas_sizes.home, local.default_pod.user_quotas_sizes.home)
      bhard = try(local.custom.user_quotas_sizes.home, local.default_pod.user_quotas_sizes.home)
      isoft = try(local.custom.user_quotas_inodes.home, local.default_pod.user_quotas_inodes.home)
      ihard = try(local.custom.user_quotas_inodes.home, local.default_pod.user_quotas_inodes.home)
    }
    project = {
      bsoft = try(local.custom.user_quotas_sizes.project, local.default_pod.user_quotas_sizes.project)
      bhard = try(local.custom.user_quotas_sizes.project, local.default_pod.user_quotas_sizes.project)
      isoft = try(local.custom.user_quotas_inodes.project, local.default_pod.user_quotas_inodes.project)
      ihard = try(local.custom.user_quotas_inodes.project, local.default_pod.user_quotas_inodes.project)
    }
    scratch = {
      bsoft = try(local.custom.user_quotas_sizes.scratch, local.default_pod.user_quotas_sizes.scratch)
      bhard = try(local.custom.user_quotas_sizes.scratch, local.default_pod.user_quotas_sizes.scratch)
      isoft = try(local.custom.user_quotas_inodes.scratch, local.default_pod.user_quotas_inodes.scratch)
      ihard = try(local.custom.user_quotas_inodes.scratch, local.default_pod.user_quotas_inodes.scratch)
    }
  }

  default = {
    mgmt_instances = {
      mgmt = {
        type = try(local.custom.instances_type_map[var.cloud_name]["mgmt"], local.default_pod.instances_type_map[var.cloud_name]["mgmt"]),
	tags = ["puppet", "mgmt", "nfs", "formation_extra", "cron"],
	disk_size = 20,
	count = 1
      }
      login = {
        type = try(local.custom.instances_type_map[var.cloud_name]["login"], local.default_pod.instances_type_map[var.cloud_name]["login"]),
	tags = try(local.custom.nnodes.jupyter, 0) == 0 ? ["login", "public", "proxy"] : ["login", "public"],
	disk_size = 20,
	count = try(local.custom.nnodes.login, 1)
      }
      jupyter = {
        type = try(local.custom.instances_type_map[var.cloud_name]["jupyter"], local.default_pod.instances_type_map[var.cloud_name]["jupyter"]),
	tags = ["public", "proxy"],
	disk_size = 20,
	count = try(local.custom.nnodes.jupyter, 0)
      }
    }
    compute_instances = {
      for flavor in try(local.custom.node_flavors[var.cloud_name], local.custom.node_flavors, local.default_pod.node_flavors[var.cloud_name]):
        flavor => {
	  type = try(local.custom.instances_type_map[var.cloud_name][flavor], local.default_pod.instances_type_map[var.cloud_name][flavor])
	  tags = try(local.custom.tags[flavor], local.default_pod.tags[flavor], ["node", "pool"])
	  disk_size = try(local.custom.disk_size[flavor], local.default_pod.disk_size[flavor], 20)
	  count = try(local.custom.nnodes[flavor], local.default_pod.nnodes[flavor], 0)
	  image = try(local.custom.image_map[flavor], local.custom.image_compute, local.default_pod.image_map[flavor], local.default_pod.image_compute)
	  mig = try(local.custom.mig[var.cloud_name][flavor], local.default_pod.mig[var.cloud_name][flavor], null)
	  shard = try(local.custom.shard[flavor], local.default_pod.shard[flavor], null)
	  features = try(local.custom.features[flavor], local.default_pod.features[flavor], ["cpu"])
	}
    }
    volumes_map = {
      arbutus = {
        nfs = {
          home     = { size = try(local.custom.home_size, local.default_pod.home_size), quota = try(local.custom.user_quotas.home, local.user_quotas.home), enable_resize = true }
          project  = { size = try(local.custom.project_size, local.default_pod.project_size), quota = try(local.custom.user_quotas.project, local.user_quotas.project), enable_resize = true  }
          scratch  = { size = try(local.custom.scratch_size, local.default_pod.scratch_size), quota = try(local.custom.user_quotas.scratch, local.user_quotas.scratch), enable_resize = true  }
        }
      }
      beluga = {
        nfs = {
          home     = { size = try(local.custom.home_size, local.default_pod.home_size), type = "volumes-ssd", quota = try(local.custom.user_quotas.home, local.user_quotas.home), enable_resize = true   }
          project  = { size = try(local.custom.project_size, local.default_pod.project_size), type = "volumes-ec", quota = try(local.custom.user_quotas.project, local.user_quotas.project), enable_resize = true   }
          scratch  = { size = try(local.custom.scratch_size, local.default_pod.scratch_size), type = "volumes-ec", quota = try(local.custom.user_quotas.scratch, local.user_quotas.scratch), enable_resize = true  }
        }
      }
      juno = {
        nfs = {
          home     = { size = try(local.custom.home_size, local.default_pod.home_size), quota = try(local.custom.user_quotas.home, local.user_quotas.home), mkfs_options = "-K", enable_resize = true  }
          project  = { size = try(local.custom.project_size, local.default_pod.project_size), quota = try(local.custom.user_quotas.project, local.user_quotas.project), mkfs_options = "-K", enable_resize = true  }
          scratch  = { size = try(local.custom.scratch_size, local.default_pod.scratch_size), quota = try(local.custom.user_quotas.scratch, local.user_quotas.scratch), mkfs_options = "-K", enable_resize = true }
        }
      }
    }
  }

  instances = try(local.custom.instances, merge(local.default.mgmt_instances, local.default.compute_instances))
  volumes = try(local.custom.volumes, local.default.volumes_map[var.cloud_name])
  cluster_purpose = try(local.custom.cluster_purpose, local.default_pod.cluster_purpose)
  nb_users = try(local.custom.nb_users, local.default_pod.nb_users)

  hieradata = yamlencode(merge(
    {
      "profile::slurm::controller::tfe_token" =  var.tfe_token
      "profile::slurm::controller::tfe_workspace" = data.tfe_workspace.current.id
      "cluster_name" = local.name
      "prometheus_password" = var.prometheus_password
      "google_calendar_id" = var.google_calendar_id
      "google_api_key" = var.google_api_key
      "cloud_name" = var.cloud_name
      "cluster_purpose" = local.cluster_purpose
    },
    var.credentials_hieradata,
    yamldecode(file("../common/config.yaml")),
  ))
}

module "openstack" {
  source         = "git::https://github.com/calculquebec/magic_castle_formation.git//openstack?ref=formation"
  config_git_url = try(local.custom.config_git_url, local.default_pod.config_git_url)
  config_version = try(local.custom.config_version, local.default_pod.config_version)

  cluster_name = "${local.name}${var.suffix}"
  domain       = "calculquebec.cloud"
  image        = try(local.custom.image, local.default_pod.image)

  instances = local.instances

  # var.pool is managed by Slurm through Terraform REST API.
  # To let Slurm manage a type of nodes, add "pool" to its tag list.
  # When using Terraform CLI, this parameter is ignored.
  # Refer to Magic Castle Documentation - Enable Magic Castle Autoscaling
  pool = var.pool

  volumes = local.volumes

  public_keys = compact(concat(split("\n", file("../keys/sshkeys.pub")), ))

  nb_users = local.nb_users
  # Shared password, randomly chosen if blank
  guest_passwd = ""

  hieradata = local.hieradata
  hieradata_dir = "./"
  eyaml_key = base64decode(var.eyaml_key)
  software_stack = "alliance"

  subnet_id = "${var.subnet_id}"
  os_ext_network = "${var.os_ext_network}"

  puppetfile = file("../common/Puppetfile")
}

output "accounts" {
  value = module.openstack.accounts
}

output "public_ip" {
  value = module.openstack.public_ip
}

# Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/calculquebec/magic_castle_formation.git//dns/cloudflare?ref=formation"
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  dkim_public_key  = file("../keys/dkim_public.pem")
}

output "hostnames" {
  value = module.dns.hostnames
}
