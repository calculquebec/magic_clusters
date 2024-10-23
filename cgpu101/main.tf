locals {
  name = "cgpu101"

  custom = {
    home_size = 200
    nnodes = {
      cpu = 0
      gpu = 1
      gpupool = 40
    }
  }
}
