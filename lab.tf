resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
  pool = var.pg.disk_pool
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}



#-----PG---------------------------------------------------------------------------------------------------------
resource "libvirt_volume" "vaultlab-pg-disk" {
  count = var.pg.count
  name = "vaultlab-pg-disk-${count.index}"
  pool = var.pg.disk_pool
  size = var.pg.disk_size
  base_volume_name = var.pg.disk_base
}

resource "libvirt_domain" "vaultlab-pg" {
  count = var.pg.count
  name = "vaultlab-${var.pg.name}-${count.index}"
  cpu {
    mode = "host-passthrough"
  }
  vcpu = var.pg.vcpu
  memory = var.pg.memory

  disk {
    volume_id = libvirt_volume.vaultlab-pg-disk["${count.index}"].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = var.pg.network
    wait_for_lease = true
  }
}

# Ansible
resource "local_file" "hosts-pg" {
  filename        = "./inventories/pg"
  file_permission = "0644"
  content = templatefile("./hosts.tpl",
    {
      node_group    = "pg"
      nodes = { for n in libvirt_domain.vaultlab-pg: "${n.name}" => n.network_interface[0].addresses[0] }
  })
}
resource "terraform_data" "ansible-pg" {
  triggers_replace = [
    local_file.hosts-pg
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=0 ANSIBLE_FORCE_COLOR=1 ansible-playbook -i inventories/ playbook-pg.yml -vv"
  }
}

#-----V----------------------------------------------------------------------------------------------------------
resource "libvirt_volume" "vaultlab-vault-disk" {
  count = var.vault.count
  name = "vaultlab-vault-disk-${count.index}"
  pool = var.vault.disk_pool
  size = var.vault.disk_size
  base_volume_name = var.vault.disk_base
}

resource "libvirt_domain" "vaultlab-vault" {
  count = var.vault.count
  name = "vaultlab-${var.vault.name}-${count.index}"
  cpu {
    mode = "host-passthrough"
  }
  vcpu = var.vault.vcpu
  memory = var.vault.memory

  disk {
    volume_id = libvirt_volume.vaultlab-vault-disk["${count.index}"].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = var.vault.network
    wait_for_lease = true
  }
}

# Ansible
resource "local_file" "hosts-vault" {
  filename        = "./inventories/vault"
  file_permission = "0644"
  content = templatefile("./hosts.tpl",
    {
      node_group    = "vault"
      nodes = { for n in libvirt_domain.vaultlab-vault: "${n.name}" => n.network_interface[0].addresses[0] }
  })
}
resource "terraform_data" "ansible-vault" {
#  depends_on = [
#    terraform_data.ansible-pg
#  ]

  triggers_replace = [
    local_file.hosts-vault,
    terraform_data.ansible-pg
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=0 ANSIBLE_FORCE_COLOR=1 ansible-playbook -i inventories/ playbook-vault.yml -v"
  }
}


#-----LB---------------------------------------------------------------------------------------------------------
resource "libvirt_volume" "vaultlab-lb-disk" {
  count = var.lb.count
  name = "vaultlab-lb-disk-${count.index}"
  pool = var.lb.disk_pool
  size = var.lb.disk_size
  base_volume_name = var.lb.disk_base
}

resource "libvirt_domain" "vaultlab-lb" {
  count = var.lb.count
  name = "vaultlab-${var.lb.name}-${count.index}"
  cpu {
    mode = "host-passthrough"
  }
  vcpu = var.lb.vcpu
  memory = var.lb.memory

  disk {
    volume_id = libvirt_volume.vaultlab-lb-disk["${count.index}"].id
  }

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_name   = var.lb.network
    wait_for_lease = true
  }
}

# Ansible
resource "local_file" "hosts-lb" {
  filename        = "./inventories/lb"
  file_permission = "0644"
  content = templatefile("./hosts.tpl",
    {
      node_group    = "lb"
      nodes = { for n in libvirt_domain.vaultlab-lb: "${n.name}" => n.network_interface[0].addresses[0] }
  })
}
resource "terraform_data" "ansible-lb" {
#  depends_on = [
#    terraform_data.ansible-vault
#  ]

  triggers_replace = [
    local_file.hosts-lb,
    terraform_data.ansible-vault
  ]

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=0 ANSIBLE_FORCE_COLOR=1 ansible-playbook -i inventories/ playbook-lb.yml -v"
  }
}
