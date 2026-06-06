#!/bin/bash
# One-time setup script. Run this before terraform init on a fresh environment.
# Creates the storage account used as the Terraform remote state backend.
set -e

RESOURCE_GROUP="alana-barrett-frew-sandbox-rg"
STORAGE_ACCOUNT="smartassignstoragetf"
CONTAINER="tfstate"
LOCATION="uksouth"

echo "Checking Azure login..."
az account show > /dev/null 2>&1 || { echo "Run 'az login' first"; exit 1; }

if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
  echo "Storage account already exists, skipping creation."
else
  echo "Creating Terraform state storage account..."
  az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --https-only true \
    --allow-blob-public-access false \
    --output none
fi

echo "Creating tfstate container (skipped if already exists)..."
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none

echo "Initialising Terraform..."
cd infra
terraform init \
  -backend-config="resource_group_name=$RESOURCE_GROUP" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT" \
  -backend-config="container_name=$CONTAINER" \
  -backend-config="key=smart-assign.tfstate"

echo ""
echo "Bootstrap complete. Now run:"
echo "  ./infra/plan.sh"
echo "  ./infra/apply.sh"
