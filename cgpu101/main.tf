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
    image_compute = "snapshot-cpunode-2026-A9.7-2"
    image_map = {
      cpupool = "snapshot-cpunode-2026-A9.7-2"
      gpupool = "snapshot-gpunode-2026-A9.7-2"
    }
  }
}
