# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
    skip_provider_registration = true
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "vnet1${var.user}"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = var.resource_group

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "subnet1${var.user}"
    resource_group_name  = var.resource_group
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "publicIP1${var.user}"
    location                     = "westeurope"
    resource_group_name          = var.resource_group
    allocation_method            = "Dynamic"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "networkSecurityGroup1${var.user}"
    location            = "westeurope"
    resource_group_name = var.resource_group
    
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

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "NIC1${var.user}"
    location                  = "westeurope"
    resource_group_name       = var.resource_group

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
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "VM1${var.user}"
    location              = "westeurope"
    resource_group_name   = var.resource_group
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = "Standard_DS1_v2"
    depends_on            = [azuread_user.workshop]
    admin_username        = var.user

    os_disk  {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    custom_data = base64encode(file("scripts/init.sh"))

    admin_ssh_key {
        username   = var.user
        public_key = file("/home/${var.user}/.ssh/id_rsa.pub")
    }

    tags = {
        environment = "Terraform Demo"
    }
}