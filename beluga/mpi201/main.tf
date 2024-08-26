locals {
  name = "mpi201"
  
  custom = {
    ncpu = 1
    n_compute_node = 8

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
