locals {
  name = "pyt301"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 1  # 6 inscriptions + 1 instructor + 3 helpers = 10 GI
    }
    mig = {
      gpupool = { "3g.20gb" = 2 }
    }
  }
}
