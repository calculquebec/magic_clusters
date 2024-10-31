locals {
  name = "cip201"

  custom = {
    nnodes = {
      cpu = 1
      cpupool = 8
      gpu = 2
      gpupool = 1
    }
    mig = {
      gpu = { "2g.10gb" = 3 }
      gpupool = { "2g.10gb" = 3 }
    }
  }
}
