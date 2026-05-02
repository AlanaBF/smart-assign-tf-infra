resource "azurerm_user_assigned_identity" "smart_assign" {
  name                = "smart-assign-managed-identity"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tags                = local.tags
}