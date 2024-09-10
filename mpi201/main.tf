locals {
  name = "mpi201"
  
  custom = {
    nnode_cpu = 1
    nnode_compute = 8

    instances_type_map = {
      arbutus = {
        cpu = "c16-90gb-392"
	compute_node = "c8-30gb-186"
      }
      beluga = {
        cpu = "p8-30gb"
	compute_node = "c8-60gb"
      }
    }
  }
}
