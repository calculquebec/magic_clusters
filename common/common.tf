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
variable "support_email" {
  type = string
  default = ""
}
variable "gitlab_token" {
  type = string
  default = ""
}
variable "gitlab_project_name" {
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
    image_compute = "snapshot-cpunode-2026-MC16-A9.8"
    image_map = {
      cpupool = "snapshot-cpunode-2026-MC16-A9.8"
      gpupool = "snapshot-gpunode-2026-MC16-A9.8"
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
    config_git_url = "https://github.com/computecanada/puppet-magic_castle.git"
    config_version = "7e03ce0"

    node_flavors = {
      arbutus = ["cpu", "compute-node", "cpupool", "gpu", "gpupool"],
      beluga = ["cpu", "compute-node", "cpupool"]
      juno = ["cpu", "cpupool", "gpu", "gpupool"]
    }
    tags = {
      cpu = ["node", "allcq"]
      gpu = ["node", "allcq"]
    }
    upgrades = {
      cpu = "vanilla-all"
      gpu = "vanilla-all"
    }
    instances_type_map = {
      arbutus = {
        mgmt = "p8-12gb"
        login = "p4-6gb"
        jupyter = "p4-6gb"
        cpu = "cb2-7.5gb-70"
        cpupool = "cb8-30gb-280"
        gpu = "g1-12gb-c3-35gb-125"
        gpupool = "g1-12gb-c3-35gb-125"
        compute-node = "cb8-30gb-280"
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
      juno = {
        gpu = { "1g.5gb" = 7 }
        gpupool = { "1g.5gb" = 7 }
      }
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
	tags = ["puppet", "mgmt", "nfs", "formation_extra", "cron", "allcq"],
	disk_size = 20,
	count = 1,
	upgrade = "vanilla-all",
      }
      login = {
        type = try(local.custom.instances_type_map[var.cloud_name]["login"], local.default_pod.instances_type_map[var.cloud_name]["login"]),
	tags = try(local.custom.nnodes.jupyter, 0) == 0 ? ["login", "public", "proxy", "allcq"] : ["login", "public", "allcq"],
	disk_size = 20,
	count = try(local.custom.nnodes.login, 1),
	upgrade = "vanilla-all",
      }
      jupyter = {
        type = try(local.custom.instances_type_map[var.cloud_name]["jupyter"], local.default_pod.instances_type_map[var.cloud_name]["jupyter"]),
	tags = ["public", "proxy", "allcq"],
	disk_size = 20,
	count = try(local.custom.nnodes.jupyter, 0),
	upgrade = "vanilla-all",
      }
    }
    compute_instances = {
      for flavor in try(local.custom.node_flavors[var.cloud_name], local.custom.node_flavors, local.default_pod.node_flavors[var.cloud_name]):
        flavor => {
	  type = try(local.custom.instances_type_map[var.cloud_name][flavor], local.custom.instances_type_map[flavor], local.default_pod.instances_type_map[var.cloud_name][flavor])
	  tags = try(local.custom.tags[flavor], local.default_pod.tags[flavor], ["node", "pool", "allcq"])
	  disk_size = try(local.custom.disk_size[flavor], local.default_pod.disk_size[flavor], 20)
	  count = try(local.custom.nnodes[flavor], local.default_pod.nnodes[flavor], 0)
	  image = try(local.custom.image_map[flavor], local.custom.image_compute, local.default_pod.image_map[flavor], local.default_pod.image_compute)
	  mig = try(local.custom.mig[var.cloud_name][flavor], local.custom.mig[flavor], local.default_pod.mig[var.cloud_name][flavor], local.default_pod.mig[flavor], null)
	  shard = try(local.custom.shard[flavor], local.default_pod.shard[flavor], null)
	  features = try(local.custom.features[flavor], local.default_pod.features[flavor], ["cpu"])
	  upgrade = try(local.custom.upgrades[flavor], local.default_pod.upgrades[flavor], "security")
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
      "cluster_name" = "${local.name}${var.suffix}"
      "prometheus_password" = var.prometheus_password
      "google_calendar_id" = var.google_calendar_id
      "google_api_key" = var.google_api_key
      "cloud_name" = var.cloud_name
      "cluster_purpose" = local.cluster_purpose
      "gitlab_token" = var.gitlab_token
    },
    var.credentials_hieradata,
    yamldecode(file("../common/config.yaml")),
  ))
}

module "openstack" {
  source         = "git::https://github.com/computecanada/magic_castle.git//openstack?ref=2dace5d"
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

terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
    }
    prettyjson = {
      source = "graysievert/prettyjson"
    }
  }
}

locals {
  assets = [
    for host in keys(module.openstack.assets): {
        host = {
          "name" = "${host}.int.${module.openstack.cluster_name}.${module.openstack.domain}",
          "id"   = "CQ/${host}.int.${module.openstack.cluster_name}.${module.openstack.domain}"
          "uuid" = module.openstack.assets[host].uuid,
          "ip"   = compact([module.openstack.assets[host].local_ip, try(module.openstack.assets[host].public_ip, "")]),
          "exposure" = coalesce(
            contains(module.openstack.assets[host].tags, "login") ? "login" : "",
            contains(module.openstack.assets[host].tags, "proxy") ? "portal" : "",
	    contains(module.openstack.assets[host].tags, "node") ? "node" : "",
            "infra"
          ),
          "type" = "virtual",
        },
        service = {
          "name" = module.openstack.cluster_name,
          "state" = "production",
          "type" = "Magic castle cluster for training",
        },
        location = {
          "site" = "${var.cloud_name} cloud"
        },
        user = {
          "email" = var.support_email
        },
      }
    ]
}

resource "gitlab_repository_file" "assets_file" {
  project = var.gitlab_project_name
  file_path = "${local.cluster_purpose}/${module.openstack.cluster_name}/assets/${module.openstack.cluster_name}-assets.json"
  branch = "main"
  encoding = "text"
  content = provider::prettyjson::jsonprettyprint(jsonencode(local.assets))
  author_email = var.support_email
  author_name = "Terraform"
  update_commit_message = "Automatic update of assets for cluster ${module.openstack.cluster_name}"
  create_commit_message = "Creating cluster ${module.openstack.cluster_name}"
  delete_commit_message = "Deleting cluster ${module.openstack.cluster_name}"
}

data "gitlab_repository_tree" "software_repository" {
  project = var.gitlab_project_name
  ref = "main"
  path = "${local.cluster_purpose}/${module.openstack.cluster_name}"
  recursive = true
  depends_on = [gitlab_repository_file.assets_file]
}
resource "terraform_data" "cleanup_assets" {
  # Capture all required values during creation so they are safe at destroy-time
  triggers_replace = {
    support_email       = var.support_email
    cluster_purpose     = local.cluster_purpose
    cluster_name        = module.openstack.cluster_name
    assets_file_path    = gitlab_repository_file.assets_file.file_path
    
    # Store the tree items as a static list of paths during creation
    blob_paths = [
      for item in data.gitlab_repository_tree.software_repository.tree : item.path
      if item.type == "blob"
    ]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOT
      curl --request POST \
        --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        --header "Content-Type: application/json" \
        --data "$API_PAYLOAD" \
        "$GITLAB_BASE_URL/projects/$GITLAB_PROJECT_ID/repository/commits"
    EOT

    environment = {
      API_PAYLOAD = jsonencode({
        branch        = "main"
        author_name   = "Terraform GitLab Bot"
        author_email  = self.triggers_replace.support_email
        commit_message = "Automated cleanup: removing files related to cluster ${self.triggers_replace.cluster_name}"
  
        # Build the dynamic delete actions array completely from self-contained trigger state
        actions = [
          for path in self.triggers_replace.blob_paths : {
            action    = "delete"
            file_path = path
          }
          if path != self.triggers_replace.assets_file_path && strcontains(path, "${self.triggers_replace.cluster_purpose}/${self.triggers_replace.cluster_name}")
        ]
      })
    }
  }
}

# Uncomment to register your domain name with CloudFlare
module "dns" {
  source           = "git::https://github.com/computecanada/magic_castle.git//dns/cloudflare?ref=4ae5ab9"
  name             = module.openstack.cluster_name
  domain           = module.openstack.domain
  public_instances = module.openstack.public_instances
  dkim_public_key  = file("../keys/dkim_public.pem")
}

output "hostnames" {
  value = module.dns.hostnames
}
