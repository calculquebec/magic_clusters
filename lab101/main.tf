locals {
  name = "lab101"
  
  custom = {
    nnode_cpu = 20
    nnode_cpupool = 20

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
