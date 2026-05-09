resource "azurerm_container_group" "etl" {
  name                = "smart-assign-etl"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Linux"
  restart_policy      = "Never"
  tags                = local.tags

  subnet_ids = [azurerm_subnet.etl.id]

  image_registry_credential {
    server   = azurerm_container_registry.smart_assign.login_server
    username = azurerm_container_registry.smart_assign.admin_username
    password = azurerm_container_registry.smart_assign.admin_password
  }

  container {
    name   = "smart-assign-etl"
    image  = "${azurerm_container_registry.smart_assign.login_server}/smart-assign-etl:latest"
    cpu    = 1
    memory = 2

    environment_variables = {
      PGHOST              = azurerm_postgresql_flexible_server.smart_assign.fqdn
      PGPORT              = "5432"
      PGDATABASE          = "postgres"
      PGUSER              = var.db_user
      PGSSLMODE           = "require"
      FLOWCASE_DATA_SOURCE = "fake"
    }

    secure_environment_variables = {
      PGPASSWORD = var.db_password
    }
  }
}
