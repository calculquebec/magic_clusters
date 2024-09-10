locals {
  name = "example"
 
  # Tout dans cette structure est *optionnel*. Si c'est omis, les valeurs par défaut sont utilisées
  custom = {
    # Images de VM à utiliser
    # image = "AlmaLinux-9"
    # image_cpu = "AlmaLinux-9"
    # image_gpu = "AlmaLinux-9"

    # Nombre de type d'instances. Les valeurs par défaut sont celles ci-dessous
    nnode_cpu = 2
    nnode_gpu = 0
    nnode_compute = 0
    nnode_cpupool = 0
    nnode_gpupool = 0

    # taille des systèmes de fichiers. Les valeurs par défaut sont celles ci-dessous
    home_size = 20
    project_size = 20
    scratch_size = 20

    # version/commit de puppet_magic-castle
    # config_version = "e64f448"
    # config_version = "14.0.0"

    # Pour choisir le type d'instance pour les différents types de noeud
    # Les valeurs ci-dessous sont les valeurs par defaut
    instances_type_map = {
      arbutus = {
        mgmt = "p8-12gb"
	login = "p4-6gb"
	cpu = "c8-30gb-186-avx2"
	cpupool = "c8-30gb-186-avx2"
	compute_node = "p8-12gb"
	gpu = "g1-8gb-c4-22gb"
	gpupool = "g1-8gb-c4-22gb"
      }
      beluga = {
        mgmt = "p4-7.5gb"
	login = "p4-7.5gb"
	cpu = "c8-60gb"
	cpupool = "c8-60gb"
	compute_node = "p8-15gb"
	gpu = "gpu32-240-3450gb-a100x1"
	gpupool = "gpu32-240-3450gb-a100x1"
      }
    }

    # Configuration MIG pour les noeuds "gpu" et "gpupool" sur Beluga
    gpu_mig_config = { "3g.20gb" = 1, "2g.10gb" = 1, "1g.5gb" = 2 }
    gpupool_mig_config = { "1g.5gb" = 7 }

    # Pour redéfinir complètement toutes les instances
    # instances = {
    #   mgmt   = { type = "p8-12gb", tags = ["puppet", "mgmt", "nfs"], count = 1 }
    #   login  = { type = "p4-6gb", tags = ["login", "public", "proxy"], count = 1 }
    #   gpu-node   = { type = "g1-8gb-c4-22gb", tags = ["node"], count = 1 }
    #   gpu-nodepool   = { type = "g1-8gb-c4-22gb", tags = ["node", "pool"], count = 40, image="snapshot-gpunode-2024.1" }
    # }

    # Pour redéfinir complètement tous les volumes: 
    # volumes = {
    #   nfs = {
    #     home     = { size = 200 }
    #     project  = { size = 20 }
    #     scratch  = { size = 20 }
    #   }
    # }
  }
}
