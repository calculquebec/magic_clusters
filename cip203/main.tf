locals {
  name = "cip203"
  
  custom = {
    nnodes = {
      cpu = 0      # Forcer 0 noeud CPU
      gpu = 0      # Fonctionner uniquement avec les gpupool
      gpupool = 5  # 5 users in total
      gpupool2 = 10 # 5 users in total x 2 MIGs
    }
    mig = {
      gpupool = { "3g.20gb" = 2 }
      gpupool2 = { "1g.5gb" = 7 }
    }
  }
}
