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

    }
    # update git config
    config_git_url = "https://github.com/computecanada/puppet-magic_castle.git"
    config_version = "15.2.1"

    mig = {
      gpupool = { "1g.5gb" = 7 }
      gpu = { "1g.5gb" = 7 }
    }

    image_compute = "AlmaLinux-9"
#    image_map = {
#      cpu = "AlmaLinux-9"
#      gpu = "AlmaLinux-9"
#    }

    # taille des systèmes de fichiers. Les valeurs par défaut sont celles ci-dessous
    home_size = 250
    project_size = 200
    scratch_size = 100
  }
}
