locals {
  name = "cip101"
  
  custom = {
    nnodes = {
      cpu = 2
      compute_node = 2
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
