locals {
  name = "iqete" 

  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 3  # 21 comptes
    }
    mig = {
      gpupool = {"1g.5gb" = 7}
    }
  }
}
