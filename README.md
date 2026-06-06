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

## First-Time Setup (Bootstrap)

The Terraform state backend storage account must exist before `terraform init` can run. A bootstrap script handles this:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

This creates the storage account, the `tfstate` container, and runs `terraform init`. Only needed once per fresh environment.

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

2. **Bootstrap (first time only):**
   ```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
   ```

3. **Plan:**
   ```bash
   ./infra/plan.sh
   # or: ./infra/plan.sh MY_PASSWORD
   ```

4. **Apply:**
   ```bash
   ./infra/apply.sh
   # or: ./infra/apply.sh MY_PASSWORD
   ```

## Destroy and Rebuild

**To destroy:**
```bash
cd infra
terraform destroy \
  -var-file="vars/global/global.tfvars" \
  -var-file="vars/global/uks/dev.tfvars" \
  -var="db_password=YOUR_PASSWORD"
```

**Before rebuilding — purge the Key Vault:**

Azure soft-deletes Key Vaults for 90 days. The name `smart-assign-kv` stays reserved until purged:
```bash
az keyvault purge --name smart-assign-kv --location uksouth
```

**Then rebuild:**
```bash
./bootstrap.sh
./infra/apply.sh
```

After apply completes, run the backend and ETL Azure DevOps pipelines to push Docker images to the freshly created ACR. The Static Web App will have a new hostname — update the frontend pipeline's deployment token from the Azure portal.

## Input Variables

| Variable | Type | Description |
|----------|------|-------------|
| `location` | string | Azure region — set in `global.tfvars` |
| `project` | string | Project short name — set in `global.tfvars` |
| `environment` | string | Environment name — set in `dev.tfvars` |
| `tags` | map(string) | Resource tags — set in `global.tfvars` |
| `db_password` | string (sensitive) | **Only required input at apply time** |

CORS origins are derived automatically from the Static Web App hostname. Key Vault secrets (`db-host`, `db-user`, `db-password`) are written by Terraform — no manual portal steps required.

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
