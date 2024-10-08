locals {
  name = "lab101"
  
  custom = {
    nnode_cpu = 16
    nnode_cpupool = 2

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
