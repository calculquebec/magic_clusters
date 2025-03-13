locals {
  name = "pyt301"
  
  custom = {
    nnodes = {
      cpu = 0
      gpu = 0
      gpupool = 4
    }
    mig = {
      gpupool = { "3g.20gb" = 2 }
    }
  }
}
