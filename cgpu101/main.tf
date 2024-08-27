locals {
  name = "cgpu101"

  custom = {
    home_size = 200
    ncpu = 0
    ngpu = 4
    image_gpu = "Rocky-8"
    ngpupool = 40
  }
}
