locals {
  name = "cip101"
  
  custom = {
    nnodes = {
      cpu = 0
      cpupool = 2
      compute-node = 2  # Requis pour les salloc et sbatch
    }

    instances_type_map = {
      arbutus = {
        cpu = "c8-60gb-186"
        compute_node = "p8-12gb"
      }
      beluga = {
        cpu = "c8-60gb"
        compute_node = "p8-15gb"
      }
    }
  }
}
