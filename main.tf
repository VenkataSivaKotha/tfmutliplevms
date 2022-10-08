# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

    subscription_id	=	"646d61b4-f2de-4539-989a-b70d0cf9cad7"
    client_id		=	"8a14f2fa-ae07-46a9-9791-2918e854651c"
    client_secret	=	"Osu8Q~Gtxj6gFM_tJTV_OzAjYbno-QgqECdgHc85"
    tenant_id		=	"a2dfc4ef-e918-4fc4-ac4b-ef6ac786213e"
    
} 

terraform {
  backend "azurerm" {
    storage_account_name = "__terrformstorageaccount__"
    container_name       = "tfstatefile"
    key                  = "terraform.tfstate"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "__storagekey__"
  }
}
 
 resource "azurerm_resource_group" "test" {
   name     = "venkatatfrg"
   location = "East US"
 }

 resource "azurerm_virtual_network" "test" {
   name                = "acctvn"
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.test.location
   resource_group_name = azurerm_resource_group.test.name
 }

 resource "azurerm_subnet" "test" {
   name                 = "acctsub"
   resource_group_name  = azurerm_resource_group.test.name
   virtual_network_name = azurerm_virtual_network.test.name
   address_prefixes     = ["10.0.2.0/24"]
 }

 resource "azurerm_public_ip" "test" {
   name                         = "publicIPForLB"
   location                     = azurerm_resource_group.test.location
   resource_group_name          = azurerm_resource_group.test.name
   allocation_method            = "Static"
 }

# resource "azurerm_lb" "test" {
#  name                = "loadBalancer"
#   location            = azurerm_resource_group.test.location
#   resource_group_name = azurerm_resource_group.test.name

#   frontend_ip_configuration {
#     name                 = "publicIPAddress"
#     public_ip_address_id = azurerm_public_ip.test.id
#   }
# }

# resource "azurerm_lb_backend_address_pool" "test" {
#   loadbalancer_id     = azurerm_lb.test.id
#   name                = "BackEndAddressPool"
# }

resource "azurerm_network_interface" "test" {
   count               = 2
   name                = "acctni${count.index}"
   location            = azurerm_resource_group.test.location
   resource_group_name = azurerm_resource_group.test.name

   ip_configuration {
     name                          = "testConfiguration"
     subnet_id                     = azurerm_subnet.test.id
     private_ip_address_allocation = "Dynamic"
   }
 }

# resource "azurerm_managed_disk" "test" {
#   count                = 2
#   name                 = "datadisk_existing_${count.index}"
#   location             = azurerm_resource_group.test.location
#   resource_group_name  = azurerm_resource_group.test.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "1023"
# }

 #resource "azurerm_availability_set" "avset" {
 #  name                         = "avset"
 #  location                     = azurerm_resource_group.test.location
 #  resource_group_name          = azurerm_resource_group.test.name
 #  platform_fault_domain_count  = 2
 #  platform_update_domain_count = 2
 #  managed                      = true
 #}
 

  resource "azurerm_windows_virtual_machine" "test" {
   count                 = 2
   name                  = "acctvm${count.index}"
   location              = azurerm_resource_group.test.location
   resource_group_name   = azurerm_resource_group.test.name
   size               = "Standard_F2"
   computer_name  = "hostname"
   admin_username = "testadmin"
   admin_password = "Password1234"
   network_interface_ids = [element(azurerm_network_interface.test.*.id, count.index)]
   
    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }

    source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
    }

    


   # Optional data disks
  # storage_data_disk {
  #   name              = "datadisk_new_${count.index}"
  #   managed_disk_type = "Standard_LRS"
  #   create_option     = "Empty"
  #   lun               = 0
  #   disk_size_gb      = "1023"
  # }

  #  storage_data_disk {
  #   name            = element(azurerm_managed_disk.test.*.name, count.index)
  #   managed_disk_id = element(azurerm_managed_disk.test.*.id, count.index)
  #   create_option   = "Attach"
  #   lun             = 1
  #   disk_size_gb    = element(azurerm_managed_disk.test.*.disk_size_gb, count.index)
  # }

   
     
   

   tags = {
     environment = "staging"
   }
 }