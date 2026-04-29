provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "remote"
  subscription_id = var.hub_subscription_id
  features {}
}

provider "azuread" {
}