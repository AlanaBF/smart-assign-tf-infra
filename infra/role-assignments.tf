resource "azurerm_role_assignment" "managed_identity_kv" {
  principal_id         = azurerm_user_assigned_identity.smart_assign.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.smart_assign.id
}

resource "azurerm_role_assignment" "managed_identity_acr" {
  principal_id         = azurerm_user_assigned_identity.smart_assign.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.smart_assign.id
}

resource "azurerm_role_assignment" "deployer_kv" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.smart_assign.id
}
