locals {
  name = "cgpu101"

  custom = {
    home_size = 800
    nnodes = {
      cpu = 0
      gpu = 0
      gpupool = 1
    }
    mig = {
      gpupool = { "3g.20gb" = 2 }
    }
    config_git_url = "https://github.com/computecanada/puppet-magic_castle.git"
    config_version = "a3c80de"
    image_cpu = "snapshot-cpunode-2026-A9.7-2"
    image_gpu = "snapshot-cpunode-2026-A9.7-2"
  }
}
