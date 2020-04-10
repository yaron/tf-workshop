# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "terraform_workshop" {
    name     = "terraformWorkshop"
    location = "westeurope"

    tags = {
        environment = "Terraform workshop"
    }
}