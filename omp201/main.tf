locals {
  name = "omp201"
  
  custom = {
    nnodes = {
      cpu = 7
    }

    instances_type_map = {
      arbutus = {
        cpu = "c4-15gb-83"
      }
      beluga = {
        cpu = "c4-15gb"
      }
    }
  }
}
