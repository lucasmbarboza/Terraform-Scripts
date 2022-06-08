variable "vcenter_username" {
  default = ""
}

variable "vcenter_password" {
  default = ""
}
variable "vcenter_server" {
  default = ""
}
variable "dc_name" {
  default = ""
}
variable "domain" {
  default = ""
}
variable "vm_name" {
  default = [""] 
}
variable "host_name" {
  default = [""] 
}
variable "ipv4_address" {
  default = [""] 
}
variable "ipv4_gateway" {
  default = ""
}
variable "vsphere_cluster" {
  default = ""
} 
variable "template_name" {
  default = "" 
}
variable "vm_network" {
  default = "VM Network" 
}
variable "vm_datastore" {
  default = ""
}
