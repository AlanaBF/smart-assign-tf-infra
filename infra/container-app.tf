resource "azurerm_container_app_environment" "smart_assign" {
  name                       = "smart-assign-env"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = var.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.smart_assign.id
  infrastructure_subnet_id   = azurerm_subnet.container_app.id
  tags                       = local.tags
}

resource "azurerm_container_app" "smart_assign" {
  name                         = "smart-assign-api"
  resource_group_name          = data.azurerm_resource_group.rg.name
  container_app_environment_id = azurerm_container_app_environment.smart_assign.id
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type = "SystemAssigned"
  }

  registry {
    server               = azurerm_container_registry.smart_assign.login_server
    username             = azurerm_container_registry.smart_assign.admin_username
    password_secret_name = "registry-password"
  }

  secret {
    name  = "registry-password"
    value = azurerm_container_registry.smart_assign.admin_password
  }

  secret {
    name                = "db-host"
    identity            = "System"
    key_vault_secret_id = azurerm_key_vault_secret.db_host.versionless_id
  }

  secret {
    name                = "db-user"
    identity            = "System"
    key_vault_secret_id = azurerm_key_vault_secret.db_user.versionless_id
  }

  secret {
    name                = "db-password"
    identity            = "System"
    key_vault_secret_id = azurerm_key_vault_secret.db_password.versionless_id
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 0
    max_replicas = 10

    container {
      name   = "smart-assign-api"
      image  = "${azurerm_container_registry.smart_assign.login_server}/smart-assign-backend:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name        = "DB_HOST"
        secret_name = "db-host"
      }
      env {
        name  = "DB_PORT"
        value = "5432"
      }
      env {
        name  = "DB_NAME"
        value = "postgres"
      }
      env {
        name        = "DB_USER"
        secret_name = "db-user"
      }
      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name  = "DB_SSLMODE"
        value = "require"
      }
      env {
        name  = "CORS_ORIGINS"
        value = "https://${azurerm_static_web_app.smart_assign.default_host_name}"
      }
    }
  }
}
