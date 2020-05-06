resource "azuread_user" "workshop" {
  count = 32
  user_principal_name = "tfWorkshop${count.index}@harryfranzenkpn.onmicrosoft.com"
  display_name        = "tfWorkshop${count.index}"
  password            = "tfWorkshoppass${count.index}"
}
resource "azuread_group" "workshop" {
  name    = "TerraformWorkshop"
  members = azuread_user.workshop[*].object_id
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.terraform_workshop.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.workshop.id
}