# Innovation Vending

This repository manages vended resource groups in the **DTS-INNOVATION-PROD** Azure subscription. Each entry in the tfvars file provisions:

- An Azure resource group (`rg-<name>-innovation-prod`)
- Subscription-level **Reader** access for the team's Entra ID group
- An Entra ID **access package** allowing team members to self-approve **Contributor** access to their resource group (8 hours per request)

Changes are applied automatically via Azure DevOps when a PR is merged to `main`.

---

## How to add a new resource group

1. Open [environments/prod/prod.tfvars](environments/prod/prod.tfvars).
2. Add a new entry to the `resource_groups` map:

```hcl
resource_groups = {
  # ... existing entries ...

  "<short-name>" = {
    end_date = "YYYY-MM-DD"
    team_entra_group = {
      name = "Name of Existing Entra ID Group"
    }
  }
}
```

| Field | Required | Description |
|---|---|---|
| **key** (e.g. `"ai"`) | Yes | Short identifier. Used in the resource group name (`rg-<key>-prod`) and Entra group names. |
| `end_date` | Yes | Expiry date for the resource group (tagged on the resource), format `YYYY-MM-DD`. |
| `team_entra_group.name` | Yes | Display name of the team's Entra ID security group. |
| `team_entra_group.existing` | No | Set to `false` if the Entra group **does not already exist** and should be created. Defaults to `true`. |
| `location` | No | Azure region. Defaults to `uksouth`. |

### Example — existing Entra group

```hcl
"platops" = {
  end_date = "2026-12-31"
  team_entra_group = {
    name = "DTS Platform Operations SC"
  }
}
```

### Example — new Entra group (created by this repo)

```hcl
"ai" = {
  end_date = "2026-12-31"
  team_entra_group = {
    name     = "DTS Innovation AI Team"
    existing = false
  }
}
```

---

## How to update an existing resource group

Edit the relevant entry in [environments/prod/prod.tfvars](environments/prod/prod.tfvars) and raise a PR. Common changes include extending the `end_date` or changing the `location`.

---

## How to remove a resource group

Delete the entry from the `resource_groups` map in [environments/prod/prod.tfvars](environments/prod/prod.tfvars) and raise a PR. Terraform will destroy the resource group and all associated Entra groups, role assignments, and access packages.

> **Warning:** Removing an entry will **destroy all Azure resources** inside that resource group. Make sure any required data has been backed up before merging.

---

## Deployment process

1. Create a branch and edit [environments/prod/prod.tfvars](environments/prod/prod.tfvars).
2. Open a PR to `main` — the pipeline will run a **Terraform plan** so you can review the changes.
3. Once approved and merged, the pipeline runs **Terraform apply** to provision the resources.

---

## What gets created per entry

For each key in `resource_groups`, the following resources are created:

| Resource | Name / Description |
|---|---|
| Resource Group | `rg-<key>-innovation-prod` |
| Entra ID Group (optional) | The team group, if `existing = false` |
| Contributor Group | `DTS Innovation <key> RG Contributor SC` |
| Contributor Eligible Group | `DTS Innovation <key> RG Contributor Eligible SC` |
| Access Package | Self-approval contributor access (8 hours) |
| Role Assignment — Reader | Team group → subscription scope |
| Role Assignment — Contributor | Contributor group → resource group scope |
