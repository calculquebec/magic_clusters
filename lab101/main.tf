locals {
  name = "lab101"
  
  custom = {
    nnodes = {
      cpu = 16
      cpupool = 2
    }

    instances_type_map = {
      arbutus = {
        cpu = "p2-3gb"
      }
      beluga = {
        cpu = "p2-3.75gb"
      }
    }
  }
}
