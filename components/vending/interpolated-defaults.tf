module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = var.builtFrom
  environment  = var.env
  product      = var.product
  expiresAfter = "3000-01-01"
}

data "azuread_group" "sub_reader" {
  display_name     = "DTS Readers (sub:dts-innovation-prod)"
  security_enabled = true
}

data "azuread_group" "team_groups" {
  for_each         = { for key, value in var.resource_groups : key => value if value.team_entra_group.existing }
  display_name     = each.value.team_entra_group.name
  security_enabled = true
}

data "azurerm_subscription" "this" {}
data "azurerm_client_config" "this" {}

locals {
  rg_names = { for key, value in var.resource_groups : key => "rg-${key}-innovation-${var.env}" }
  tags     = { for key, value in var.resource_groups : key => merge(module.ctags.common_tags, { "expiry_date" = value.end_date, "owner" = value.team_entra_group.name }) }
}
