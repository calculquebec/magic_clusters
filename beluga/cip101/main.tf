locals {
  name = "cip101"
  
  custom = {
    instances = {
      mgmt   = { type = "p4-7.5gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
      login  = { type = "p4-7.5gb", tags = ["login", "public", "proxy"], count = 1 }
      node   = { type = "c8-60gb", tags = ["node"], count = 2 }
      compute-node =	{ type = "p8-15gb", tags = ["node"], count = 2 }
    }
  }
}