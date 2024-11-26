locals {
  name = "cgpu101"

  custom = {
    home_size = 200
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
