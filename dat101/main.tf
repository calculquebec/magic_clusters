locals {
  name = "dat101"
  
  custom = {
    nnodes = {
      cpu = 1      # Pour tester a l'avance
      cpupool = 10  # 1 par personne : seulement 6 inscriptions + helpers
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
