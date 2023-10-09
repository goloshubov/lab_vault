variable "pg" {
  description = "pg settings"

  default = {
    count          = 1
    name           = "pg"
    vcpu           = 2
    memory         = "4096"
    disk_size      = 53687091200
    disk_pool      = "ST1000DM003"
    disk_base      = "CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
    network        = "default"
  }
}

variable "lb" {
  description = "lb settings"

  default = {
    count          = 1
    name           = "lb"
    vcpu           = 2
    memory         = "4096"
    disk_size      = 53687091200
    disk_pool      = "ST1000DM003"
    disk_base      = "CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
    network        = "default"
  }
}

variable "vault" {
  description = "vault settings"

  default = {
    count          = 2
    name           = "vault"
    vcpu           = 2
    memory         = "4096"
    disk_size      = 53687091200
    disk_pool      = "ST1000DM003"
    disk_base      = "CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
    network        = "default"
  }
}


