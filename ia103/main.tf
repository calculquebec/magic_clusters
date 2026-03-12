locals {
  name = "ia103"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 1  # 20 sessions Jupyter Lab (un 1g.5gb chaque)
    }
    mig = {
      gpupool = {"1g.5gb" = 7}
    }
  }
}
