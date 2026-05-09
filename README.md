# Smart Assign - Terraform Infrastructure

Infrastructure as Code for the Smart Assign application. Provisions all Azure resources using Terraform.

## Tech Stack

- **IaC Tool:** Terraform (>= 1.0, < 2.0)
- **Cloud Provider:** Microsoft Azure
- **Providers:** AzureRM (>= 4.0), AzureAD (>= 3.0)
- **State Backend:** Azure Storage Account
- **CI/CD:** Azure Pipelines with OIDC authentication

## What Gets Provisioned

| Resource | Name | Purpose |
|----------|------|---------|
| Container Apps Environment | `smart-assign-env` | Hosts the backend API container |
| Container App | `smart-assign-api` | Runs the FastAPI backend (0.5 CPU, 1Gi RAM, 0-10 replicas) |
| PostgreSQL Flexible Server | `smart-assign-db` | Database (v17, Burstable B1ms, 32GB) |
| Static Web App | `smart-assign-frontend` | Hosts the React frontend (Free tier) |
| Container Registry | `smartassignregistry` | Stores Docker images (Basic SKU) |
| Key Vault | `smart-assign-kv` | Stores database credentials |
| Virtual Network | `smart-assign-vnet` | Network isolation (10.0.0.0/16) |
| Private Endpoint | `smart-assign-db-pe` | Private DB access from VNet |
| Private DNS Zone | `privatelink.postgres.database.azure.com` | DNS resolution for private endpoint |
| Log Analytics Workspace | — | Monitoring and logging (30-day retention) |
| Storage Account | `smartassignstoragetf` | Terraform remote state |
| Managed Identity | `smart-assign-managed-identity` | RBAC access for Container App |

## Project Structure

```
smart-assign-tf-infra/
├── infra/
│   ├── _terraform.tf          # Backend and provider version constraints
│   ├── _providers.tf          # Provider configuration
│   ├── _locals.tf             # Local variables and naming conventions
│   ├── _tags.tf               # Common resource tags
│   ├── _data.tf               # Data sources
│   ├── variables.tf           # Input variables
│   ├── networking.tf          # VNet, subnets, private DNS
│   ├── database.tf            # PostgreSQL server and private endpoint
│   ├── container-app.tf       # Container Apps environment and app
│   ├── container-registry.tf  # ACR
│   ├── key-vault.tf           # Key Vault and secrets
│   ├── static-web-app.tf      # Frontend hosting
│   ├── identity.tf            # Managed identities
│   ├── role-assignments.tf    # RBAC role assignments
│   ├── monitoring.tf          # Log Analytics
│   ├── storage.tf             # Storage account (TF state)
│   └── vars/
│       └── global/
│           ├── global.tfvars  # Shared variables (location, project, tags)
│           └── uks/
│               └── dev.tfvars # Dev environment variables
└── .azuredevops/
    └── azure-pipelines.yaml   # CI/CD pipeline definition
```

## Prerequisites

- Terraform >= 1.0
- Azure CLI (`az login` for local use)
- Access to the target Azure subscription and resource group

## Network Architecture

```
VNet: 10.0.0.0/16
├── Public Subnet:    10.0.1.0/24
├── Private Subnet:   10.0.2.0/24  (DB private endpoint at 10.0.2.4)
└── Container Subnet: 10.0.3.0/24  (Container Apps delegation)
```

The PostgreSQL database has **public access disabled**. It is only reachable via the private endpoint within the VNet.

## Local Usage

1. **Authenticate:**
   ```bash
   az login
   ```

2. **Initialise Terraform:**
   ```bash
   cd infra
   terraform init \
     -backend-config="resource_group_name=<YOUR_RESOURCE_GROUP>" \
     -backend-config="storage_account_name=<YOUR_STORAGE_ACCOUNT>" \
     -backend-config="container_name=tfstate" \
     -backend-config="key=smart-assign.tfstate"
   ```

3. **Plan:**
   ```bash
   terraform plan \
     -var-file="vars/global/global.tfvars" \
     -var-file="vars/global/uks/dev.tfvars" \
     -var="db_password=YOUR_PASSWORD"
   ```

4. **Apply:**
   ```bash
   terraform apply \
     -var-file="vars/global/global.tfvars" \
     -var-file="vars/global/uks/dev.tfvars" \
     -var="db_password=YOUR_PASSWORD"
   ```

## Input Variables

| Variable | Type | Description |
|----------|------|-------------|
| `location` | string | Azure region (e.g., `uksouth`) |
| `project` | string | Project short name (e.g., `sa`) |
| `environment` | string | Environment name (e.g., `dev`) |
| `tags` | map(string) | Resource tags |
| `db_password` | string (sensitive) | PostgreSQL admin password |
| `cors_origins` | string | Allowed CORS origins for the backend |

## CI/CD Pipeline

**Trigger:** Push to `main` branch

**Authentication:** OIDC (OpenID Connect) with an Azure Service Principal — no long-lived secrets.

**Stages:**
1. **TerraformPlan** — Installs Terraform 1.8.5, runs `terraform init` and `terraform plan`, publishes the plan as an artifact
2. **TerraformApply** — Downloads the plan artifact and runs `terraform apply` (auto-approved)

**Pipeline variables required:**
- `DB_PASSWORD` — stored in the Azure Pipelines variable group (secret)
- Azure service connection named "Azure subscription"

## Remote State

| Setting | Value |
|---------|-------|
| Backend | Azure Storage (azurerm) |
| Resource Group | Defined at `terraform init` via `-backend-config` |
| Storage Account | Defined at `terraform init` via `-backend-config` |
| Container | `tfstate` |
| State Key | `smart-assign.tfstate` |

## Important Notes

- All resources are in UK South except the Static Web App (West Europe — Azure limitation for Free tier).
- The database has no geo-redundant backups and 7-day retention. This is acceptable for sandbox but not production.
- There is only one environment (`dev`). Adding more environments requires additional tfvars files and pipeline parameterisation.
- The Container Registry has admin access enabled. For production, disable admin and use managed identity pulls exclusively.
