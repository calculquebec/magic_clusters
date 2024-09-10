locals {
  name = "dat101"
  
  custom = {
    nnode_cpu = 55
	
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