terraform {
required_version = ">= 0.14.0"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  ## Configuration options
  uri   = "qemu+ssh://gitlab-kvm@myip/system?keyfile=/home/gitlab-runner/.ssh/id_rsa&sshauth=privkey"
}

#################Variables hostname#################

variable "hostname" {
type = list(string)
default = ["kvnode01.lab.local","kvnode02.lab.local","kvnode03.lab.local"]
}
variable "domain" { default = "local" }
variable "memoryMB" { default = 1024*4 }
variable "cpu" { default = 4 }

resource "libvirt_volume" "os_image" {
count = length(var.hostname)
name = "os_image.${var.hostname[count.index]}"
pool = "VMs_Pool" 
source = "https://repo.almalinux.org/almalinux/8/cloud/x86_64/images/AlmaLinux-8-GenericCloud-8.7-20221111.x86_64.qcow2"
}

resource "libvirt_cloudinit_disk" "commoninit" {
count = length(var.hostname)
name = "${var.hostname[count.index]}-commoninit.iso"
pool = "VMs_Pool"
user_data = data.template_file.user_data[count.index].rendered
network_config = data.template_file.network_data.rendered
}

# User Data config
data "template_file" "user_data" {
  count = length(var.hostname)
  template = file("${path.module}/user_init.cfg")
  vars = {
  hostname = element(var.hostname, count.index)
  fqdn = "${var.hostname[count.index]}.${var.domain}"}
}

# Network Data config
data "template_file" "network_data" {
  template = file("${path.module}/network_init.cfg")
}

#################VM Deployment#################

resource "libvirt_domain" "domain-almalinux" {
  count = length(var.hostname)
  name = "${var.hostname[count.index]}"
  memory = var.memoryMB
  vcpu = var.cpu
  
disk {
  volume_id = element(libvirt_volume.os_image.*.id, count.index)
  }
  
network_interface {
  network_name = "lan-vagrant-libvirt"
  }
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

console {
  type = "pty"
  target_type = "serial"
  target_port = "0"
  }

graphics {
  type = "spice"
  listen_type = "address"
  autoport = true
  }
}

output "ips" {
  value = libvirt_domain.domain-almalinux.*.network_interface.0.addresses
}