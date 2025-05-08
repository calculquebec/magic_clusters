locals {
  name = "ecole"
 
  custom = {
    nnodes = {
      cpu = 0
      gpu = 0
      compute_node = 0
      cpupool = 15
      gpupool = 15
      # instance jupyter séparée
      jupyter = 1
    }

    mig = {
      gpupool = { "3g.20gb" = 2 }
    }

    # taille des systèmes de fichiers. Les valeurs par défaut sont celles ci-dessous
    home_size = 20
    project_size = 200
    scratch_size = 100
  }
}
