terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "= 0.7.1"
    }
  }
}

provider "libvirt" {
  #uri = "qemu+ssh://goloshubov@ws/system"
  uri = "qemu:///system"
}
