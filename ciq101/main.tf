locals {
  name = "ciq101"
  
  custom = {
    nnode_cpu = 0
    nnode_cpupool = 4
    nnode_gpupool = 1
    image_cpu = "snapshot-cpunode-2024-R810.5"
    image_gpu = "snapshot-gpunode-2024-R810.5"
  }
}
