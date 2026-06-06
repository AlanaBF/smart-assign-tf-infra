resource "azurerm_role_assignment" "container_app_kv_secrets_user" {
  scope                = azurerm_key_vault.smart_assign.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.smart_assign.identity[0].principal_id
}
