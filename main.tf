terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.46.0"
    }
  }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "mid" {
  name     = "rsg-mid"
  location = "West Europe"
}

resource "azurerm_virtual_network" "mid" {
  name                = "mid-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.mid.location
  resource_group_name = azurerm_resource_group.mid.name
}

resource "azurerm_subnet" "mid" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.mid.name
  virtual_network_name = azurerm_virtual_network.mid.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "mid" {
  name                = "mid-nic"
  location            = azurerm_resource_group.mid.location
  resource_group_name = azurerm_resource_group.mid.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mid.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "mid" {
  name                = "VMLU01"
  resource_group_name = azurerm_resource_group.mid.name
  location            = azurerm_resource_group.mid.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.mid.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }
} #
