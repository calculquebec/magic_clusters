locals {
  name = "lab101"
  
  custom = {
    ncpu = 1
	ncpupool = 20
	
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