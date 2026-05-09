resource "azurerm_container_registry" "smart_assign" {
  name                = "smartassignregistry"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.tags
}