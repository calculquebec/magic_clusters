locals {
  name = "cip203"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 8  # 20 sessions Jupyter Lab (un 1g.5gb chaque)
    }
    mig = {
      gpupool = {"3g.20gb" = 2}
    }
  }
}
