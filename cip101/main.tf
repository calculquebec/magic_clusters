locals {
  name = "cip101"
  
  custom = {
    nnodes = {
      cpu = 3
      compute_node = 3
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
