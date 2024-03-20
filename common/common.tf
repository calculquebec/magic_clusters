terraform {
  required_version = ">= 1.4.0"
}

variable "pool" {
  description = "Slurm pool of compute nodes"
  default = []
}

variable "TFC_WORKSPACE_NAME" { type = string }
variable "tfe_token" {}
variable "cloud_name" { type = string }
variable "prometheus_password" {}
variable "credentials_hieradata" { default= "" }

data "tfe_workspace" "current" {
  name         = var.TFC_WORKSPACE_NAME
  organization = "CalculQuebec"
}

locals {
  default_pod = {
    image_cpu = "snapshot-cpunode-2024.1"
    image_gpu = "snapshot-gpunode-2024.1"
    ncpu = 0
    ncpupool = 2
    ngpu = 0
    ngpupool = 2
    home_size = 20
    project_size = 20
    scratch_size = 10
    cluster_purpose = "formation"
  }
  
  default = {
    instances_map = {
      arbutus = {
          mgmt   = { type = "p8-12gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
          login  = { type = "p4-6gb-avx2", tags = ["login", "public", "proxy"], count = 1 }
          cpu-node   = { 
            type = "c8-30gb-186-avx2", 
            tags = ["node"], 
            count = try(local.custom.ncpu, local.default_pod.ncpu), 
            image = try(local.custom.image_cpu, local.default_pod.image_cpu),
          }
          cpu-nodepool   = { 
            type = "c8-30gb-186-avx2", 
            tags = ["node", "pool"], 
            count = try(local.custom.ncpupool, local.default_pod.ncpupool), 
            image = try(local.custom.image_cpu, local.default_pod.image_cpu),
          }
          gpu-node   = { 
            type = "g1-8gb-c4-22gb", 
            tags = ["node"], 
            count = try(local.custom.ngpu, local.default_pod.ngpu), 
            image = try(local.custom.image_gpu, local.default_pod.image_gpu),
          }
          gpu-nodepool   = { 
            type = "g1-8gb-c4-22gb", 
            tags = ["node", "pool"], 
            count = try(local.custom.ngpupool, local.default_pod.ngpupool), 
            image = try(local.custom.image_gpu, local.default_pod.image_gpu),
          }
      }
      beluga = {
          mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
          login  = { type = "p4-7.5gb", tags = ["login", "public", "proxy"], count = 1 }
          cpu-node   = { 
            type = "c8-60gb", 
            tags = ["node"], 
            count = try(local.custom.ncpu, local.default_pod.ncpu), 
            image = try(local.custom.image_cpu, local.default_pod.image_cpu),
          }
          cpu-nodepool   = { 
            type = "c8-60gb", 
            tags = ["node", "pool"], 
            count = try(local.custom.ncpupool, local.default_pod.ncpupool), 
            image = try(local.custom.image_cpu, local.default_pod.image_cpu),
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
          home     = { size = try(local.custom.home_size, local.default_pod.home_size), type = "volumes-ssd"  }
          project  = { size = try(local.custom.project_size, local.default_pod.project_size), type = "volumes-ec"  }
          scratch  = { size = try(local.custom.scratch_size, local.default_pod.scratch_size), type = "volumes-ec"  }
        }
      }
    }
  }
  
  volumes = try(local.custom.volumes, local.default.volumes_map[var.cloud_name])
  cluster_purpose = try(local.custom.cluster_purpose, local.default_pod.cluster_purpose)
  instances = try(local.custom.instances, local.default.instances_map[var.cloud_name])

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
    yamldecode(file("../../common/config.yaml")),
    yamldecode(file("config.yaml"))
  ))
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
