resource "azurerm_postgresql_flexible_server" "smart_assign" {
  name                          = "smart-assign-db"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = var.location
  version                       = "17"
  administrator_login           = var.db_user
  administrator_password        = var.db_password
  zone                          = "1"
  storage_mb                    = 32768
  storage_tier                  = "P4"
  sku_name                      = "B_Standard_B1ms"
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = false

  authentication {
    active_directory_auth_enabled = false
    password_auth_enabled         = true
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "smart_assign" {
  name                          = "smart-assign-db-pe"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = var.location
  subnet_id                     = azurerm_subnet.private.id
  custom_network_interface_name = "smart-assign-db-pe-nic"
  tags                          = local.tags

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.smart_assign.id]
  }

  private_service_connection {
    name                           = "smart-assign-db-pe"
    private_connection_resource_id = azurerm_postgresql_flexible_server.smart_assign.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
}