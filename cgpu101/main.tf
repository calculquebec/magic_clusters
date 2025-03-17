locals {
  name = "cgpu101"

  custom = {
    home_size = 800
    nnodes = {
      cpu = 0
      gpu = 0
      gpupool = 8
    }
    mig = {
      gpupool = { "3g.20gb" = 2 }
    }
  }
}
