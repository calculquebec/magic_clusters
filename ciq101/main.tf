locals {
  name = "ciq101"
  
  custom = {
    nnodes = {
      cpu = 0
      cpupool = 3  # Maximum 14 personnes par noeud
      gpupool = 0
    }
  }
}
