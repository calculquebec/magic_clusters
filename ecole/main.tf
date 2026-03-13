locals {
  name = "ecole"
 
  custom = {
    nnodes = {
      cpu = 1
      gpu = 1
      compute_node = 0
      cpupool = 15
      gpupool = 15
      # instance jupyter séparée
      jupyter = 1

      # update git config
      config_git_url = "https://github.com/computecanada/puppet-magic_castle.git"
      config_version = "15.2.1"
    }

    instances_type_map = {
      juno = {
        login = "ha4-15gb"
      }
    }

    mig = {
      gpupool = { "1g.5gb" = 7 }
    }

    image_cpu = "AlmaLinux-9"
    image_gpu = "AlmaLinux-9"
#    image_cpu = "snapshot-cpunode-2025-A9.4-ecole"
#    image_gpu = "snapshot-gpunode-2025-A9.4-ecole"

    # taille des systèmes de fichiers. Les valeurs par défaut sont celles ci-dessous
    home_size = 250
    project_size = 200
    scratch_size = 100
  }
}
