data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "smart_assign" {
  name                       = "smart-assign-kv2"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 90
  rbac_authorization_enabled = true
  tags                       = local.tags
}
