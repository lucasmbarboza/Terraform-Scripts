# provider "vsphere" {
#   user           = var.vcenter_username
#   password       = var.vcenter_password
#   vsphere_server = var.vcenter_server
#    # If you have a self-signed cert
#   allow_unverified_ssl = true
# }

data "vsphere_datacenter" "dc" {
  name = var.dc_name
}

data "vsphere_datastore" "datastore" {
  name          = var.vm_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "default" {
  name          = format("%s%s", data.vsphere_compute_cluster.cluster.name, "/Resources")
  datacenter_id = data.vsphere_datacenter.dc.id
}
#--------------- Resources ---------------------------

resource "vsphere_virtual_machine" "vm" {
  count            = length(var.vm_name)
  name             = var.vm_name[count.index]
  datastore_id     = data.vsphere_datastore.datastore.id #length(var.vm_datastore) > 1 ? var.vm_datastore[count+1].id : var.vm_datastore[0].id
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  num_cpus         = 4
  memory           = 8192
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout =  0
  wait_for_guest_net_routable = false
  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }
  disk {
    label            = "${var.vm_name[count.index]}.vmdk"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    linked_clone  = "false"

    customize {
        linux_options {
        host_name = "${var.host_name[count.index]}"
        domain    = "${var.domain}"
      }
      network_interface {
        ipv4_address = "${var.ipv4_address[count.index]}"
        ipv4_netmask = 24
      }
      ipv4_gateway    = "${var.ipv4_gateway}"
      dns_server_list = ["8.8.8.8"]
    }
  }
}
