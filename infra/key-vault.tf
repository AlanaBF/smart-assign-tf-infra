data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "smart_assign" {
  name                       = "smart-assign-kv"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 90
  enable_rbac_authorization  = true
  tags                       = local.tags
}

resource "azurerm_key_vault_secret" "db_host" {
  name         = "db-host"
  value        = azurerm_postgresql_flexible_server.smart_assign.fqdn
  key_vault_id = azurerm_key_vault.smart_assign.id
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-user"
  value        = var.db_user
  key_vault_id = azurerm_key_vault.smart_assign.id
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.smart_assign.id
}