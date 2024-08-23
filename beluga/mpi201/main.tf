locals {
  name = "mpi201"
  
  custom = {
    instances = {
      mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
      login  = { type = "p4-7.5gb", tags = ["login", "public", "proxy"], count = 1 }
      jh-node   = { type = "p8-30gb", tags = ["node"], count = 2 }
      compute-node =	{ type = "c8-60gb", tags = ["node"], count = 8 }
    }
  }
}