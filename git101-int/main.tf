locals {
  name = "gitint101"
  
  custom = {
    nnode_cpu = 10

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
