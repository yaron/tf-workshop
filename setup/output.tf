output "ssh_command" {
    value = "ssh  azureuser@${azurerm_public_ip.myterraformpublicip.ip_address}"
}