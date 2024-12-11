

###############################################
# Data Sources (salt-master)
###############################################

#TBD


###############################################
# Resources (salt-master)
###############################################

###### ressource group ######

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-resources"
  location = var.location
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-NetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.242.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-vnet-internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.242.2.0/24"]
}

###### salt-master ######

resource "azurerm_network_interface" "saltmaster" {
  name                = "${var.prefix}-saltmaster-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "saltmaster" {
  name                            = "${var.prefix}-saltmaster"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "salt-admin"
  admin_password                  = var.adminuser
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.saltmaster.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

#   provisioner "remote-exec" {
#     inline = [
#       "ls -la /tmp",
#     ]

#     connection {
#       host     = self.public_ip_address
#       user     = self.admin_username
#       password = self.admin_password
#     }
#   }
  custom_data = "${base64encode(file("./cloud-init/cloud-init.yml"))}"
}



###### Bastion ######

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.242.3.0/26"]
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix}-bastion-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.prefix}-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

###### salt-minion1 #######

resource "azurerm_network_interface" "saltminion1" {
  name                = "${var.prefix}-saltminion1-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "saltminion1" {
  name                            = "${var.prefix}-saltminion1"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "salt-admin"
  admin_password                  = var.adminuser
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.saltminion1.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

#   provisioner "remote-exec" {
#     inline = [
#       "ls -la /tmp",
#     ]

#     connection {
#       host     = self.public_ip_address
#       user     = self.admin_username
#       password = self.admin_password
#     }
#   }
  custom_data = "${base64encode(file("./cloud-init-minion1/cloud-init.yml"))}"
}

###### salt-minion2 #######

resource "azurerm_network_interface" "saltminion2" {
  name                = "${var.prefix}-saltminion2-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "saltminion2" {
  name                            = "${var.prefix}-saltminion2"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "salt-admin"
  admin_password                  = var.adminuser
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.saltminion2.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }


  custom_data = "${base64encode(file("./cloud-init-minion2/cloud-init.yml"))}"
}

###### salt-minion3 #######

resource "azurerm_network_interface" "saltminion3" {
  name                = "${var.prefix}-saltminion3-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "saltminion3" {
  name                            = "${var.prefix}-saltminion3"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "salt-admin"
  admin_password                  = var.adminuser
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.saltminion3.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }


  custom_data = "${base64encode(file("./cloud-init-minion3/cloud-init.yml"))}"
}
