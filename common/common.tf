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
    image_cpu = "snapshot-cpunode-2025.3-A9.6"
    image_gpu = "snapshot-gpunode-2025.3-A9.6"
    nb_users = 0

    nnodes = {
      cpu = 2
      compute_node = 0
      gpu = 0
      cpupool = 0
      gpupool = 0
      jupyter = 0
      login = 1
      gpupool12 = 0
      gpupool16 = 0
      gpupool80 = 0
      gpupool16-cq = 0
      gpupool12-j = 0
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
    config_version = "a3d5b02"

    instances_type_map = {
      arbutus = {
        mgmt = "p8-12gb"
        login = "p4-6gb"
        jupyter = "p4-6gb"
        cpu = "c8-30gb-186-avx2"
        cpupool = "c8-30gb-186-avx2"
        compute_node = "p8-12gb"
        gpu = "g1-8gb-c4-22gb"
        gpupool = "g1-8gb-c4-22gb"
      }
      beluga = {
        mgmt = "p4-7.5gb"
        login = "p4-7.5gb"
        jupyter = "p4-7.5gb"
        cpu = "c8-60gb"
        cpupool = "c8-60gb"
        compute_node = "p8-15gb"
      }
      juno = {
        mgmt = "ha4-15gb"
        login = "c4-15gb"
        jupyter = "c4-15gb"
        cpu = "c8-30gb"
        cpupool = "c8-30gb"
	gpu = "gpu16-240-3450gb-a100x1_cq"
        gpupool = "gpu12-120-850gb-a100x1_MC"
        gpupool16 = "gpu16-240-3375gb-a100x1"
        gpupool80 = "gpu13-240-2500gb-a100-80gx1"
        gpupool12 = "gpu12-120-850gb-a100x1"
	gpupool16-cq = "gpu16-240-3450gb-a100x1_cq"
	gpupool12-j = "gpu12-120-850gb-a100x1_j"
      }
    }

    mig = {
      gpu = { "1g.5gb" = 7 }
      gpupool = { "1g.5gb" = 7 }
      gpupool16 = { "1g.5gb" = 7 }
      gpupool80 = { "1g.10gb" = 7 }
      gpupool12 = { "1g.5gb" = 7 }
      gpupool16-cq = { "1g.5gb" = 7 }
      gpupool12-j = { "1g.5gb" = 7 }
    }

    shard = {
      gpu = null
      gpupool = null
      gpupool16 = null
      gpupool80 = null
      gpupool12 = null
      gpupool16-cq = null
      gpupool12-j = null
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
    instances_map = {
      arbutus = {
        mgmt = {
          type = try(local.custom.instances_type_map.arbutus.mgmt, local.default_pod.instances_type_map.arbutus.mgmt),
          tags = ["puppet", "mgmt", "nfs", "formation_extra", "cron"],
          disk_size = 20,
          count = 1
        }
        login = {
          type = try(local.custom.instances_type_map.arbutus.login, local.default_pod.instances_type_map.arbutus.login),
          tags = try(local.custom.nnodes.jupyter, local.default_pod.nnodes.jupyter) == 0 ? ["login", "public", "proxy"] : ["login", "public"],
          disk_size = 20,
          count = try(local.custom.nnodes.login, local.default_pod.nnodes.login)
        }
        jupyter = {
          type = try(local.custom.instances_type_map.arbutus.jupyter, local.default_pod.instances_type_map.arbutus.jupyter),
          tags = ["public", "proxy"],
          disk_size = 20,
          count = try(local.custom.nnodes.jupyter, local.default_pod.nnodes.jupyter)
        }
        nodecpu = {
          type = try(local.custom.instances_type_map.arbutus.cpu, local.default_pod.instances_type_map.arbutus.cpu),
          tags = ["node"],
          count = try(local.custom.nnodes.cpu, local.default_pod.nnodes.cpu),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        compute-node = {
          type = try(local.custom.instances_type_map.arbutus.compute_node, local.default_pod.instances_type_map.arbutus.compute_node),
          tags = ["node"],
          count = try(local.custom.nnodes.compute_node, local.default_pod.nnodes.compute_node),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodecpupool = {
          type = try(local.custom.instances_type_map.arbutus.cpupool, local.default_pod.instances_type_map.arbutus.cpupool),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.cpupool, local.default_pod.nnodes.cpupool),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodegpu = {
          type = try(local.custom.instances_type_map.arbutus.gpu, local.default_pod.instances_type_map.arbutus.gpu),
          tags = ["node"],
          count = try(local.custom.nnodes.gpu, local.default_pod.nnodes.gpu),
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpu, local.default_pod.shard.gpu),
        }
        nodegpupool = {
          type = try(local.custom.instances_type_map.arbutus.gpupool, local.default_pod.instances_type_map.arbutus.gpupool),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool, local.default_pod.nnodes.gpupool),
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool, local.default_pod.shard.gpupool),
        }
      }
      beluga = {
        mgmt = {
          type = try(local.custom.instances_type_map.beluga.mgmt, local.default_pod.instances_type_map.beluga.mgmt),
          tags = ["puppet", "mgmt", "nfs", "formation_extra", "cron"],
          disk_size = 20,
          count = 1
        }
        login = {
          type = try(local.custom.instances_type_map.beluga.login, local.default_pod.instances_type_map.beluga.login),
          tags = try(local.custom.nnodes.jupyter, local.default_pod.nnodes.jupyter) == 0 ? ["login", "public", "proxy"] : ["login", "public"],
          disk_size = 20,
          count = try(local.custom.nnodes.login, local.default_pod.nnodes.login)
        }
        jupyter = {
          type = try(local.custom.instances_type_map.beluga.jupyter, local.default_pod.instances_type_map.beluga.jupyter),
          tags = ["public", "proxy"],
          disk_size = 20,
          count = try(local.custom.nnodes.jupyter, local.default_pod.nnodes.jupyter)
        }
        nodecpu = {
          type = try(local.custom.instances_type_map.beluga.cpu, local.default_pod.instances_type_map.beluga.cpu),
          disk_size = 20
          tags = ["node"],
          count = try(local.custom.nnodes.cpu, local.default_pod.nnodes.cpu),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        compute-node = {
          type = try(local.custom.instances_type_map.beluga.compute_node, local.default_pod.instances_type_map.beluga.compute_node),
          disk_size = 20
          tags = ["node"],
          count = try(local.custom.nnodes.compute_node, local.default_pod.nnodes.compute_node),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodecpupool = {
          type = try(local.custom.instances_type_map.beluga.cpupool, local.default_pod.instances_type_map.beluga.cpupool),
          disk_size = 20
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.cpupool, local.default_pod.nnodes.cpupool),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
      }
      juno = {
        mgmt = {
          type = try(local.custom.instances_type_map.juno.mgmt, local.default_pod.instances_type_map.juno.mgmt),
          tags = ["puppet", "mgmt", "nfs", "formation_extra", "cron"],
          disk_size = 20,
          count = 1
        }
        login = {
          type = try(local.custom.instances_type_map.juno.login, local.default_pod.instances_type_map.juno.login),
          tags = try(local.custom.nnodes.jupyter, local.default_pod.nnodes.jupyter) == 0 ? ["login", "public", "proxy"] : ["login", "public"],
          disk_size = 20,
          count = try(local.custom.nnodes.login, local.default_pod.nnodes.login)
        }
        jupyter = {
          type = try(local.custom.instances_type_map.juno.jupyter, local.default_pod.instances_type_map.juno.jupyter),
          tags = ["public", "proxy"],
          disk_size = 20,
          count = try(local.custom.nnodes.jupyter, local.default_pod.nnodes.jupyter)
        }
        nodecpu = {
          type = try(local.custom.instances_type_map.juno.cpu, local.default_pod.instances_type_map.juno.cpu),
          disk_size = 20
          tags = ["node"],
          count = try(local.custom.nnodes.cpu, local.default_pod.nnodes.cpu),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodecpupool = {
          type = try(local.custom.instances_type_map.juno.cpupool, local.default_pod.instances_type_map.juno.cpupool),
          disk_size = 20
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.cpupool, local.default_pod.nnodes.cpupool),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodegpu = {
          type = try(local.custom.instances_type_map.juno.gpu, local.default_pod.instances_type_map.juno.gpu),
          tags = ["node"],
          count = try(local.custom.nnodes.gpu, local.default_pod.nnodes.gpu),
          mig = try(local.custom.mig.gpu, local.default_pod.mig.gpu)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpu, local.default_pod.shard.gpu),
          disk_size = "50"
        }
        nodegpupool = {
          type = try(local.custom.instances_type_map.juno.gpupool, local.default_pod.instances_type_map.juno.gpupool),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool, 0),
          mig = try(local.custom.mig.gpupool, local.default_pod.mig.gpupool)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool, local.default_pod.shard.gpupool),
          disk_size = "50"
        }
        nodegpupool16 = {
          type = try(local.custom.instances_type_map.juno.gpupool16, local.default_pod.instances_type_map.juno.gpupool16),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool16, 0),
          mig = try(local.custom.mig.gpupool16, local.default_pod.mig.gpupool16)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool16, local.default_pod.shard.gpupool16),
          disk_size = "50"
        }
        nodegpupool16-cq = {
          type = try(local.custom.instances_type_map.juno.gpupool16-cq, local.default_pod.instances_type_map.juno.gpupool16-cq),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool16-cq, 0),
          mig = try(local.custom.mig.gpupool16-cq, local.default_pod.mig.gpupool16-cq)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool16-cq, local.default_pod.shard.gpupool16-cq),
          disk_size = "50"
        }
        nodegpupool12 = {
          type = try(local.custom.instances_type_map.juno.gpupool12, local.default_pod.instances_type_map.juno.gpupool12),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool12, 0),
          mig = try(local.custom.mig.gpupool12, local.default_pod.mig.gpupool12)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool12, local.default_pod.shard.gpupool12),
          disk_size = "50"
        }
        nodegpupool12-j = {
          type = try(local.custom.instances_type_map.juno.gpupool12-j, local.default_pod.instances_type_map.juno.gpupool12-j),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool12-j, 0),
          mig = try(local.custom.mig.gpupool12-j, local.default_pod.mig.gpupool12-j)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool12-j, local.default_pod.shard.gpupool12-j),
          disk_size = "50"
        }
        nodegpupool80 = {
          type = try(local.custom.instances_type_map.juno.gpupool80, local.default_pod.instances_type_map.juno.gpupool80),
          tags = ["node", "pool"],
          count = try(local.custom.nnodes.gpupool80, 0),
          mig = try(local.custom.mig.gpupool80, local.default_pod.mig.gpupool80)
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
	  shard = try(local.custom.shard.gpupool80, local.default_pod.shard.gpupool80),
          disk_size = "50"
        }
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

  instances = try(local.custom.instances, local.default.instances_map[var.cloud_name])
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
