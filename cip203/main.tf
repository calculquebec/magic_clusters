locals {
  name = "cip203"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 4  # 14 sessions Jupyter Lab (un 1g.5gb chaque)
    }
    mig = {
      gpupool = {"1g.5gb" = 4, "3g.20gb" = 1}
    }
  }
}
