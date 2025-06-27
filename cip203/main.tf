locals {
  name = "cip203"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 2  # 2 users in total
    }
    mig = {
      gpupool = { "3g.20gb" = 1, "1g.5gb" = 4}
    }
  }
}
