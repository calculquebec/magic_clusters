locals {
  name = "cip101"
  
  custom = {
    nnode_cpu = 2
    nnode_compute = 2

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
