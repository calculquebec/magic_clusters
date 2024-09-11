locals {
  name = "paraview"

  custom = {
    home_size = 100
    project_size = 100
    scrach_size = 100

    instances_type_map = {
      arbutus = {
        cpu = "c4-30gb-83"
      }
      beluga = {
        cpu = "c4-30gb"
      }
    }
  }
}
