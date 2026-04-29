
resource "azurerm_role_assignment" "func_acr_pull" {
  principal_id         = "041105cf-ca73-48bb-b7ae-010737aa3977"
  role_definition_name = "AcrPull"
  scope                = "/subscriptions/4ac7e4ba-2b33-4c38-8852-1a6ba4098aa3/resourceGroups/alana-barrett-frew-sandbox-rg/providers/Microsoft.ContainerRegistry/registries/smartassignregistry"
}