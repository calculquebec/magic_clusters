locals {
  name = "cip203"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 4  # 12 sessions Jupyter Lab (un 1g.5gb chaque)
    }
    mig = {
      gpupool = {"1g.5gb" = 3, "3g.20gb" = 1}
    }
  }
}
