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
variable "prometheus_password" {
  type = string
  default = ""
}
variable "credentials_hieradata" { default= {} }
variable "suffix" {
  type = string
  default = ""
}
data "tfe_workspace" "current" {
  name         = var.TFC_WORKSPACE_NAME
  organization = "CalculQuebec"
}

locals {
  default_pod = {
    image = "Rocky-8"
    image_cpu = "snapshot-cpunode-2024-R810.5"
    image_gpu = "snapshot-gpunode-2024-R810.4"
    nnode_cpu = 2
    nnode_gpu = 0
    nnode_compute = 0
    nnode_cpupool = 0
    nnode_gpupool = 0
    home_size = 20
    project_size = 20
    scratch_size = 20
    cluster_purpose = "formation"
    config_version = "1ba3a12"

    instances_type_map = {
      arbutus = {
        mgmt = "p8-12gb"
        login = "p4-6gb"
        cpu = "c8-30gb-186-avx2"
        cpupool = "c8-30gb-186-avx2"
        compute_node = "p8-12gb"
        gpu = "g1-8gb-c4-22gb"
        gpupool = "g1-8gb-c4-22gb"
      }
      beluga = {
        mgmt = "p4-7.5gb"
        login = "p4-7.5gb"
        cpu = "c8-60gb"
        cpupool = "c8-60gb"
        compute_node = "p8-15gb"
        gpu = "gpu32-240-3450gb-a100x1"
        gpupool = "gpu32-240-3450gb-a100x1"
      }
    }

    gpu_mig_config = { "3g.20gb" = 1, "2g.10gb" = 1, "1g.5gb" = 2 }
    gpupool_mig_config = { "1g.5gb" = 7 }
  }

  default = {
    instances_map = {
      arbutus = {
        mgmt = {
          type = try(local.custom.instances_type_map.arbutus.mgmt, local.default_pod.instances_type_map.arbutus.mgmt),
          tags = ["puppet", "mgmt", "nfs"],
          count = 1
        }
        login = {
          type = try(local.custom.instances_type_map.arbutus.login, local.default_pod.instances_type_map.arbutus.login),
          tags = ["login", "public", "proxy"],
          count = 1
    	  }
        nodecpu = {
          type = try(local.custom.instances_type_map.arbutus.cpu, local.default_pod.instances_type_map.arbutus.cpu),
          tags = ["node"],
          count = try(local.custom.nnode_cpu, local.default_pod.nnode_cpu),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        compute-node = {
          type = try(local.custom.instances_type_map.arbutus.compute_node, local.default_pod.instances_type_map.arbutus.compute_node),
          tags = ["node"],
          count = try(local.custom.nnode_compute, local.default_pod.nnode_compute),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodecpupool = {
          type = try(local.custom.instances_type_map.arbutus.cpupool, local.default_pod.instances_type_map.arbutus.cpupool),
          tags = ["node", "pool"],
          count = try(local.custom.nnode_cpupool, local.default_pod.nnode_cpupool),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodegpu = {
          type = try(local.custom.instances_type_map.arbutus.gpu, local.default_pod.instances_type_map.arbutus.gpu),
          tags = ["node"],
          count = try(local.custom.nnode_gpu, local.default_pod.nnode_gpu),
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
        }
        nodegpupool = {
          type = try(local.custom.instances_type_map.arbutus.gpupool, local.default_pod.instances_type_map.arbutus.gpupool),
          tags = ["node", "pool"],
          count = try(local.custom.nnode_gpupool, local.default_pod.nnode_gpupool),
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
        }
      }
      beluga = {
        mgmt = {
          type = try(local.custom.instances_type_map.beluga.mgmt, local.default_pod.instances_type_map.beluga.mgmt),
          tags = ["puppet", "mgmt", "nfs"],
          count = 1
        }
        login  = {
          type = try(local.custom.instances_type_map.beluga.login, local.default_pod.instances_type_map.beluga.login),
          tags = ["login", "public", "proxy"],
          count = 1
    	  }
        nodecpu = {
          type = try(local.custom.instances_type_map.beluga.cpu, local.default_pod.instances_type_map.beluga.cpu),
          disk_size = 20
          tags = ["node"],
          count = try(local.custom.nnode_cpu, local.default_pod.nnode_cpu),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        compute-node = {
          type = try(local.custom.instances_type_map.beluga.compute_node, local.default_pod.instances_type_map.beluga.compute_node),
          disk_size = 20
          tags = ["node"],
          count = try(local.custom.nnode_compute, local.default_pod.nnode_compute),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodecpupool = {
          type = try(local.custom.instances_type_map.beluga.cpupool, local.default_pod.instances_type_map.beluga.cpupool),
          disk_size = 20
          tags = ["node", "pool"],
          count = try(local.custom.nnode_cpupool, local.default_pod.nnode_cpupool),
          image = try(local.custom.image_cpu, local.default_pod.image_cpu),
        }
        nodegpu = {
          type = try(local.custom.instances_type_map.beluga.gpu, local.default_pod.instances_type_map.beluga.gpu),
          tags = ["node"],
          count = try(local.custom.nnode_gpu, local.default_pod.nnode_gpu),
          mig = try(local.custom.gpu_mig_config, local.default_pod.gpu_mig_config),
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
          disk_size = "50"
        }
        nodegpupool = {
          type = try(local.custom.instances_type_map.beluga.gpupool, local.default_pod.instances_type_map.beluga.gpupool),
          tags = ["node", "pool"],
          count = try(local.custom.nnode_gpupool, local.default_pod.nnode_gpupool),
          mig = try(local.custom.gpupool_mig_config, local.default_pod.gpupool_mig_config),
          image = try(local.custom.image_gpu, local.default_pod.image_gpu),
          disk_size = "50"
        }
      }
    }
    volumes_map = {
      arbutus = {
        nfs = {
          home     = { size = try(local.custom.home_size, local.default_pod.home_size) }
          project  = { size = try(local.custom.project_size, local.default_pod.project_size) }
          scratch  = { size = try(local.custom.scratch_size, local.default_pod.scratch_size) }
        }
      }
      beluga = {
        nfs = {
          home     = { size = try(local.custom.home_size, local.default_pod.home_size), type = "volumes-ssd" }
          project  = { size = try(local.custom.project_size, local.default_pod.project_size), type = "volumes-ec" }
          scratch  = { size = try(local.custom.scratch_size, local.default_pod.scratch_size), type = "volumes-ec" }
        }
      }
    }
  }

  instances = try(local.custom.instances, local.default.instances_map[var.cloud_name])
  volumes = try(local.custom.volumes, local.default.volumes_map[var.cloud_name])
  cluster_purpose = try(local.custom.cluster_purpose, local.default_pod.cluster_purpose)

  hieradata = yamlencode(merge(
    {
      "profile::slurm::controller::tfe_token" =  var.tfe_token
      "profile::slurm::controller::tfe_workspace" = data.tfe_workspace.current.id
      "cluster_name" = local.name
      "prometheus_password" = var.prometheus_password
      "cloud_name" = var.cloud_name
      "cluster_purpose" = local.cluster_purpose
    },
    var.credentials_hieradata,
    yamldecode(file("../common/config.yaml")),
    yamldecode(file("config.yaml"))
  ))
}

module "openstack" {
  source         = "git::https://github.com/ComputeCanada/magic_castle.git//openstack?ref=14.0.0-beta"
  config_git_url = "https://github.com/ComputeCanada/puppet-magic_castle.git"
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

  public_keys = compact(concat(split("\n", file("../common/sshkeys.pub")), ))

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
  source           = "git::https://github.com/ComputeCanada/magic_castle.git//dns/cloudflare?ref=14.0.0-beta"
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
}

output "hostnames" {
  value = module.dns.hostnames
}
