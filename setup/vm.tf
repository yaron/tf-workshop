
# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.terraform_workshop.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.terraform_workshop.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.terraform_workshop.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.terraform_workshop.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WEB_SSH"
        priority                   = 3000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3000"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "westeurope"
    resource_group_name       = azurerm_resource_group.terraform_workshop.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface_security_group_association" "mynicsg" {
  network_interface_id      = azurerm_network_interface.myterraformnic.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "westeurope"
    resource_group_name   = azurerm_resource_group.terraform_workshop.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "myvm"
        admin_username = "azureuser"
        custom_data = file("scripts/init.sh")
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDT/A23+p1SxGcqD17zEA26eamBHfrAF3IBiZkVktbraThLRBStGAw2QUfGtISD0E2P39Br3sciI//DkTz0ClPPAsDzKDFRFHmYpzBRRS+WqpLxMXmWtFSqzjRMyvtecu9EAwdLldH/Qe6LiSg0PG8aY3LeZlGfmEbMt0peQOP5HFESZWh0yXcQHQPVju51EoWF5JlEBI+NmdDjH7ZzXjLJhPuKtiV4Ex15F1JxH9GnPoyY49oQjW0+PkbP+2dgfIQRclza0W0n+BLFAjHADBNd8bmjnaK+OMT3VgXiHIzk1wE+kPUTeBQYZrnWCcYNCPeMx0U9n3CsmhNh0Cbh+rQHFk0xpBLW7gaihLd+8OQpeU6GmIwwsWrJP2oGGFLH8V2GOHRpNNY7X0fZQA/exwVDQoJrxTYdcASwaOGo/syT84oh2UbeAtzPT7wrtQPeH6lMgadVPv4In8iRqmc6xbQiu6ZSTbptbCYuaCdmVoyJvAZtdnGWNrmog9NnI6gMksQhbWhg1GX/vECL3DIdg2Er945GO1p/QB/jqpFHIhHoMjG7qQ+0VrKAW1B4mx0SLYEHwSAoV+J77cuUy9lrSldLUgTwYPktHEaShisllAfy5z5QBbkU5aqsYSj7BV++BV2wYfDsU5ck8DVUJxN0lE8XTUHXE3YtjcHKyRW4ooCGLQ=="
        }
    }

    tags = {
        environment = "Terraform Demo"
    }
}
