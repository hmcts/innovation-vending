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

data "azuread_group" "sub_contributor" {
  display_name     = "DTS Contributors (sub:dts-innovation-prod)"
  security_enabled = true
}

data "azurerm_subscription" "this" {}
data "azurerm_client_config" "this" {}

resource "time_static" "creation_datetime" {
  for_each = local.resource_groups
}

locals {
  resource_groups = { for idx, value in var.resource_groups : format("%03d", idx + 1) => value }
  rg_names        = { for key, value in local.resource_groups : key => "rg-${key}-innovation-${var.env}" }
  tags            = { for key, value in local.resource_groups : key => merge(module.ctags.common_tags, { "expiry_date" = value.end_date, "owner" = value.owner.team_name != null ? value.owner.team_name : value.owner.name, "owner_email" = value.owner.email }) }
}
