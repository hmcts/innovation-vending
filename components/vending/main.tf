resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups
  name     = local.rg_names[each.key]
  location = each.value.location
  tags     = local.tags[each.key]
}

resource "azuread_group_member" "sub_readers" {
  for_each         = var.resource_groups
  group_object_id  = data.azuread_group.sub_reader.id
  member_object_id = data.azuread_group.team_groups[each.key].id
}

resource "azuread_group" "team_groups" {
  for_each         = { for key, value in var.resource_groups : key => value if value.team_entra_group.existing == false }
  display_name     = each.value.team_entra_group.name
  security_enabled = true
}

resource "azuread_group" "contributor" {
  for_each         = var.resource_groups
  display_name     = "DTS Innovation ${each.key} RG Contributor SC"
  security_enabled = true
  description      = "Allows contributor access to the ${local.rg_names[each.key]} resource group in DTS-INNOVATION-PROD. Access should be gained via an access package."
}

resource "azuread_group" "contributor_eligible" {
  for_each         = var.resource_groups
  display_name     = "DTS Innovation ${each.key} RG Contributor Eligible SC"
  security_enabled = true
  description      = "Allows users to request contributor access to the ${local.rg_names[each.key]} resource group in DTS-INNOVATION-PROD."
}

resource "azuread_group_member" "contributor_eligible" {
  for_each         = var.resource_groups
  group_object_id  = azuread_group.contributor_eligible[each.key].id
  member_object_id = each.value.team_entra_group.existing ? data.azuread_group.team_groups[each.key].object_id : azuread_group.team_groups[each.key].object_id
}

resource "azurerm_role_assignment" "reader" {
  for_each             = var.resource_groups
  principal_id         = each.value.team_entra_group.existing ? data.azuread_group.team_groups[each.key].object_id : azuread_group.team_groups[each.key].object_id
  scope                = data.azurerm_subscription.this.id
  role_definition_name = "Reader"
}

resource "azurerm_role_assignment" "contributor" {
  for_each             = var.resource_groups
  principal_id         = azuread_group.contributor[each.key].id
  scope                = azurerm_resource_group.this[each.key].id
  role_definition_name = "Contributor"
}
