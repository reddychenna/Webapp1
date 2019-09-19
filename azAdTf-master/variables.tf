variable "location" {
 description = "The location where resources will be created"
 default = "eastus"
}

variable "tags" {
 description = "A map of the tags to use for the resources that are deployed"
 type        = "map"

 default = {
   environment = "codelab"
 }
}

variable "resource_group_name" {
 description = "The name of the resource group in which the resources will be created"
 default     = "paidGroup1"
}
variable "application_port" {
   description = "The port that you want to expose to the external load balancer"
   default     = 22
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM Scale Set"
   default     = "clouduser"
}

variable "admin_password" {
   description = "Default password for admin account"
   default = "Azure12345678$"
}
