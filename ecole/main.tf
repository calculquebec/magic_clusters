locals {
  name = "ecole"
 
  custom = {
    nnodes = {
      cpu = 0
      gpu = 0
      compute_node = 0
      cpupool = 10
      gpupool = 6
      # instance jupyter séparée
      jupyter = 1

    }

    image_map = {
      gpupool = "snapshot-gpunode-2026-A9.7-ecole"
      cpupool = "snapshot-cpunode-2026-A9.7-ecole"
    }
    mig = {
      gpupool = { "1g.5gb" = 7 }
    }

    # taille des systèmes de fichiers. Les valeurs par défaut sont celles ci-dessous
    home_size = 250
    project_size = 200
    scratch_size = 100

    user_quotas_sizes = {
      home = "5g"
      project = "4g"
      scratch = "5g"
    }
  }
}
