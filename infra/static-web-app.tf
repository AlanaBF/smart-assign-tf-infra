resource "azurerm_static_web_app" "smart_assign" {
  name                = "smart-assign-frontend"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = "westeurope"
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = local.tags
}