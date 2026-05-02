resource "azurerm_log_analytics_workspace" "smart_assign" {
  name                = "workspacealanabarrettfrewsandboxrg92df"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}
