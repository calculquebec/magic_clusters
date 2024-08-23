locals {
  name = "cip101"
  
  custom = {
    instances = {
	  mgmt   = { type = "p4-6gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
	  login  = { type = "p4-6gb", tags = ["login", "public", "proxy"], count = 1 }
	  node   = { type = "c8-60gb-186", tags = ["node"], count = 1 }
	  compute-node = { type = "p8-12gb", tags = ["node"], count = 2 }
	}
  }
}