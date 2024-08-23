locals {
  name = "mpi201"
  
  custom = {
    instances = {
	  mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
      login  = { type = "p4-6gb", tags = ["login", "public", "proxy"], count = 1 }
      jh-node   = { type = "c16-90gb-392", tags = ["node"], count = 1 }
      compute-node =	{ type = "c8-30gb-186", tags = ["node"], count = 8 }
    }
  }
}