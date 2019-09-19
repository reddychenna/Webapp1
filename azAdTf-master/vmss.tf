resource "azurerm_resource_group" "vmss" {
 name     = "${var.resource_group_name}"
 location = "${var.location}"
 tags     = "${var.tags}"
}

resource "random_string" "fqdn" {
 length  = 6
 special = false
 upper   = false
 number  = false
}

resource "azurerm_virtual_network" "vmss" {
 name                = "vmss-vnet"
 address_space       = ["10.2.0.0/20"]
 location            = "${var.location}"
 resource_group_name = "${azurerm_resource_group.vmss.name}"
 tags                = "${var.tags}"
}

resource "azurerm_subnet" "vmss" {
 name                 = "vmss-subnet"
 resource_group_name  = "${azurerm_resource_group.vmss.name}"
 virtual_network_name = "${azurerm_virtual_network.vmss.name}"
 address_prefix       = "10.2.1.0/24"
}

#resource "azuread_user" "createuser" {
#  user_principal_name = "user18@autonomicpro.com"
#  display_name        = "Eighteen User"
#  mail_nickname       = "UserEighteen"
#  password            = "SecretP@sswd88!"
#}


resource "azurerm_public_ip" "vmss" {
 name                         = "vmss-public-ip"
 location                     = "${var.location}"
 resource_group_name          = "${azurerm_resource_group.vmss.name}"
 allocation_method = "Static"
 domain_name_label            = "${random_string.fqdn.result}"
 tags                         = "${var.tags}"
}

resource "azurerm_lb" "vmss" {
 name                = "vmss-lb"
 location            = "${var.location}"
 resource_group_name = "${azurerm_resource_group.vmss.name}"

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = "${azurerm_public_ip.vmss.id}"
 }

 tags = "${var.tags}"
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = "${azurerm_resource_group.vmss.name}"
 loadbalancer_id     = "${azurerm_lb.vmss.id}"
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
 resource_group_name = "${azurerm_resource_group.vmss.name}"
 loadbalancer_id     = "${azurerm_lb.vmss.id}"
 name                = "ssh-running-probe"
 port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = "${azurerm_resource_group.vmss.name}"
   loadbalancer_id                = "${azurerm_lb.vmss.id}"
   name                           = "ssh"
   protocol                       = "Tcp"
   frontend_port                  = "${var.application_port}"
   backend_port                   = "${var.application_port}"
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = "${azurerm_lb_probe.vmss.id}"
}

resource "azurerm_virtual_machine_scale_set" "vmss" {
 name                = "vmscaleset"
 location            = "${var.location}"
 resource_group_name = "${azurerm_resource_group.vmss.name}"
 upgrade_policy_mode = "Manual"

 sku {
   name     = "Standard_B1ms"
   tier     = "Standard"
   capacity = 2
 }

 storage_profile_image_reference {
   publisher = "Canonical"
   offer     = "UbuntuServer"
   sku       = "16.04-LTS"
   version   = "latest"
 }

 storage_profile_os_disk {
   name              = ""
   caching           = "ReadWrite"
   create_option     = "FromImage"
   managed_disk_type = "Standard_LRS"
 }

 storage_profile_data_disk {
   lun          = 0
   caching        = "ReadWrite"
   create_option  = "Empty"
   disk_size_gb   = 10
 }

 os_profile {
   computer_name_prefix = "vmlab"
   admin_username       = "${var.admin_user}"
   admin_password       = "${var.admin_password}"
   custom_data    = <<-EOF
      #!/bin/bash
      touch /tmp/file1.txt
      sudo snap install docker
      sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      echo export ARM_CLIENT_ID=\"3d587273-dcac-47f1-b714-72f244c67c52\" >> /home/"${var.admin_user}"/.bash_profile
      echo export ARM_CLIENT_SECRET=\"8ec3a20c-e55e-4341-abec-28d57eab3be1\" >> /home/"${var.admin_user}"/.bash_profile
      echo export ARM_SUBSCRIPTION_ID=\"6a47561d-9fe1-414e-85b7-99cd2ce0ce46\" >> /home/"${var.admin_user}"/.bash_profile
      echo export ARM_TENANT_ID=\"59b2865a-7fb8-4ccb-ab68-72cbca88fc48\" >> /home/"${var.admin_user}"/.bash_profile
      source /home/"${var.admin_user}"/.bash_profile
      sudo cp provider.tf  /home/"${var.admin_user}"
      sudo apt install unzip
      sudo wget https://releases.hashicorp.com/terraform/0.12.7/terraform_0.12.7_linux_amd64.zip
      unzip terraform_0.12.7_linux_amd64.zip
      sudo mv terraform /usr/local/bin/
      #cp provider.tf  /home/"${var.admin_user}" #
      EOF
 }

 os_profile_linux_config {
   disable_password_authentication = false
 }


 network_profile {
   name    = "terraformnetworkprofile"
   primary = true

   ip_configuration {
     name                                   = "IPConfiguration"
     subnet_id                              = "${azurerm_subnet.vmss.id}"
     load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
     primary = true
   }
 }
 
 extension {
    name                 = "AADLoginForLinux"
    publisher            = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
    type                 = "AADLoginForLinux"
    type_handler_version = "1.0"
 }
#provisioner "local-exec" {
#    command = "az login --service-principal --username \"3d587273-dcac-47f1-b714-72f244c67c52\"  --password \"8ec3a20c-e55e-4341-abec-28d57eab3be1\" --tenant \"59b2865a-7fb8-4ccb-ab68-72cbca88fc48\" "
#}

##provisioner "local-exec" { 
#    command = "az role assignment create --role \"Virtual Machine Administrator Login\" --assignee \"nineuser@autonomicpro.com\"" 
#}

 tags = "${var.tags}"
}

#resource "azurerm_role_assignment" "test" {
#  scope                = "${azurerm_virtual_machine_scale_set.vmss.name}"
#  role_definition_name = "Owner"
#  principal_id         = "nineuser@autonomicpro.com"
#}



