locals {
  name = "testcip101"
  
  custom = {
    nnodes = {
      cpu = 1
    }
      beluga = {
        cpu = "c8-60gb"
	compute_node = "p8-15gb"
      }
    }
  }
}
