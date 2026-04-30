# Innovation Vending

This repository manages vended resource groups in the **DTS-INNOVATION-PROD** Azure subscription. Each entry in the tfvars file provisions:

- An Azure resource group (`rg-<id>-innovation-prod`)
- Entra ID groups for **Contributor** and **Contributor Eligible** access
- A **Contributor** role assignment scoped to the resource group
- Membership of the subscription-level **Readers** group
- An Entra ID **access package** allowing eligible users to self-approve **Contributor** access to their resource group (8 hours per request)
- A monthly consumption **budget** with email alerts to the owner

Changes are applied automatically via Azure DevOps when a PR is merged to `main`.

---

## How to add a new resource group

1. Open [environments/prod/prod.tfvars](environments/prod/prod.tfvars).
2. Add a new entry to the `resource_groups` map using the next available 3-digit key:

```hcl
resource_groups = {
  # ... existing entries ...

  "003" = {
    end_date = "YYYY-MM-DD"
    owner = {
      name  = "Full Name"
      email = "email@justice.gov.uk"
    }
  }
}
```

The map key is a 3-digit number (`"001"`, `"002"`, `"003"`, …) that you assign manually. Use the next sequential number after the highest existing key. This identifier is used in resource group names and Entra group names.

> **Important:** Once assigned, never change or reuse a key. Since the key is part of the Terraform resource address, changing it will destroy and recreate the associated resources.

| Field | Required | Description |
|---|---|---|
| **key** (e.g. `"001"`) | Yes | 3-digit identifier. Used in the resource group name (`rg-<key>-innovation-prod`) and Entra group names. |
| `end_date` | Yes | Expiry date for the resource group (tagged on the resource), format `YYYY-MM-DD`. |
| `owner.name` | Yes | Name of the owner (individual or point of contact). |
| `owner.email` | Yes | Email address of the owner. Used for budget alert notifications. |
| `owner.team_name` | No | Team name. If provided, used as the `owner` tag on the resource group instead of `owner.name`. |
| `location` | No | Azure region. Defaults to `uksouth`. |
| `budget` | No | Monthly budget in GBP for the resource group. Defaults to `1000`. |

### Example — individual owner

```hcl
"001" = {
  end_date = "2026-12-31"
  owner = {
    name  = "Alex Bance"
    email = "alex.bance@justice.gov.uk"
  }
}
```

### Example — team owner with custom budget

```hcl
"002" = {
  end_date = "2026-12-31"
  owner = {
    team_name = "DTS Platform Operations"
    name      = "Alex Bance"
    email     = "alex.bance@justice.gov.uk"
  }
  budget = 2000
}
```

---

## How to update an existing resource group

Edit the relevant entry in [environments/prod/prod.tfvars](environments/prod/prod.tfvars) and raise a PR. Common changes include extending the `end_date`, updating the `owner`, or adjusting the `budget`. Do **not** change the entry's key.

---

## How to remove a resource group

Delete the entry from the `resource_groups` map in [environments/prod/prod.tfvars](environments/prod/prod.tfvars) and raise a PR. Terraform will destroy the resource group and all associated Entra groups, role assignments, and access packages.

> **Warning:** Removing an entry will **destroy all Azure resources** inside that resource group. Make sure any required data has been backed up before merging.

---

## Granting users access

> **Important:** After a resource group is created, users who need access must be added to the **Contributor Eligible** Entra ID group for that resource group. The group is named:
>
> `DTS Innovation prod rg-<id>-innovation-prod Contributor Eligible SC`
>
> (e.g. `DTS Innovation prod rg-001-innovation-prod Contributor Eligible SC`)
>
> Only members of this group can request Contributor access via the self-approval access package. Without being in this group, users will not be able to request access.

Once added to the Contributor Eligible group, users can request time-limited Contributor access (8 hours) through the **My Access** portal. Access is self-approved — no manager approval is required.

---

## Deployment process

1. Create a branch and edit [environments/prod/prod.tfvars](environments/prod/prod.tfvars).
2. Open a PR to `main` — the pipeline will run a **Terraform plan** so you can review the changes.
3. Once approved and merged, the pipeline runs **Terraform apply** to provision the resources.

---

## What gets created per entry

For each entry in `resource_groups`, the following resources are created (where `<id>` is the 3-digit key you assign, e.g. `001`):

| Resource | Name / Description |
|---|---|
| Resource Group | `rg-<id>-innovation-prod` |
| Contributor Group | `DTS Innovation prod rg-<id>-innovation-prod Contributor SC` |
| Contributor Eligible Group | `DTS Innovation prod rg-<id>-innovation-prod Contributor Eligible SC` |
| Contributor Role Assignment | Contributor role scoped to the resource group |
| Subscription Readers membership | Contributor Eligible group added to `DTS Readers (sub:dts-innovation-prod)` |
| Access Package | Self-approval contributor access (8 hours) |
| Budget | Monthly consumption budget with alerts at 90% and 100% |
