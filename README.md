# Magic Clusters
Magic castle recipes for various workshops

## Structure of this repository
The directory [common](https://github.com/calculquebec/magic_clusters/tree/common/common) contains most of the Magic Castle configuration in the form of a `common.tf` file which defines 
the typical `openstack` and `dns` modules. It however defines it in a way that is customizable through [Terraform Locals](https://developer.hashicorp.com/terraform/language/values/locals). 
The directory also contains a `config.yaml` file which contains useful defaults that don't need to be redefined in specific workshop directories. Finally, it contains a `sshkeys.pub` file
which contains public SSH keys which will be injected into the resulting clusters. 

The directory [example](https://github.com/calculquebec/magic_clusters/tree/common/example) contains an example of a cluster in which we would redefine many of the parameters of a cluster. 

Other directories using a course code are for specific workshops. In each of these directories, there must be a *symbolic link* to `../common/common.tf`, which will include the configuration
as define in that file. Make sure that this is a symbolic link, and not a copy, or your configuration will diverge.

## Terraform parameters
The `main.tf` file that you create for the course should have the following structure: 
```
locals {
  name = "course_code"

  custom ={
    # parameters which you want to customize
  }
}
``` 

### Most frequent locals to customize
In most cases, the only terraform locals which you want to customize will be
| Parameter | Description | Default value | 
| --- | --- | --- | 
| `nnode_cpu` | Number of static CPU nodes in the cluster | 2 |
| `nnode_cpupool` | Maximum number of CPU nodes that can be booted dynamically by Slurm | 0 |
| `nnode_gpu` | Number of static GPU nodes in the cluster | 0 |
| `nnode_gpupool` | Maximum number of GPU nodes that can be booted dynamically by Slurm | 0 |
| `home_size` | Size of the /home filesystem in GB | 20 | 
| `project_size` | Size of the /project filesystem in GB | 20 |
| `scratch_size` | Size of the /scratch filesystem in GB | 20 | 

A typical configuration might therefore be as simple as: 
```
locals {
  name = "example"
  
  custom = {
    nnode_cpu = 5
    nnode_gpupool = 2
    home_size = 50
  }
}
``` 


### Other locals that can be customized
In some rare cases, you may want to customize the following local variables: 
| Parameter | Description | Default value | 
| --- | --- | --- | 
| `image` | Default image to use for login and management VMs | Rocky-8 | 
| `image_cpu` | Default image to use for CPU node VMs | snapshot-cpunode-2024-R810.4 | 
| `image_gpu` | Default image to use for CPU node VMs | snapshot-gpunode-2024-R810.4 | 
| `nnode_compute` | Number of CPU nodes of a second type | 0 | 
| `config_version` | Version of [puppet-magic_castle](https://github.com/computecanada/puppet-magic_castle) to use | see `common.tf` |
| `gpu_mig_config` | MIG configuration used for static GPU nodes (for Béluga-cloud only) | `{ "3g.20gb" = 1, "2g.10gb" = 1, "1g.5gb" = 2 }` | 
| `gpupool_mig_config` | MIG configuration used for static GPU nodes (for Béluga-cloud only) | `{ "1g.5gb" = 7 }` | 

The `common.tf` file also defines a map of flavours of virtual machines to be used, for Arbutus and Béluga. This map can be completely or partially redefined. Default values are
```
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
``` 

For example, if you simply want to change the type of CPU node for Béluga, you could define:
```
locals {
  ...
  custom = {
    instances_type_map = {
      beluga = {
        cpu = "c4-30gb"
      }
    }
  }
}
```

If the above customizations are not enough, you can also completely redefine the `instances` or the `volumes` variable. See [here](https://github.com/calculquebec/magic_clusters/blob/common/example/main.tf#L54)
for an example.

## Puppet YAML configuration
Any parameter specified in the `config.yaml` file inside of the course directory will override the default value that may be defined in the `common` directory. For a sampling of some useful puppet parameters, see
in [the example folder](https://github.com/calculquebec/magic_clusters/blob/common/example/config.yaml). For an exhaustive list, see the [Magic Castle documentation](https://github.com/computecanada/puppet-magic_castle).

## Terraform variables
If you use a dynamic pool of node, you will want to configure a Terraform variable of type HCL, named `pool`, with value `[]`. 

The name of the cluster will be based on the `name` variable as defined in the `locals`. If you want, you can define a Terraform variable named `cloud_suffix`, which will be appended to the `name`. 
This may be useful if you want to start two clusters, one in Arbutus, one in Béluga-cloud, using the same configuration.

## YAML Validation
### Local (client-side) pre-commit hook
One can validate and lint the YAML configuration files locally by using `yamllint` and the provided configuration and hook.
The hook is ran before a commit operation and checks files that are **staged** for commit.

1. Install `yamllint` locally with your preferred method (`pip`, system package manager, ...).
For installation instructions, see [quickstart](https://yamllint.readthedocs.io/en/stable/quickstart.html)

2. Copy the hook and ensure it is executable
```bash
cd $(git rev-parse --show-toplevel)
cp -v .templates/hooks/pre-commit .git/hooks/
```
or create a symbolic link:
```bash
cd $(git rev-parse --show-toplevel)
ln -rs .templates/hooks/pre-commit .git/hooks/pre-commit
```
