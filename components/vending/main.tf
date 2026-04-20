resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups
  name     = local.rg_names[each.key]
  location = each.value.location
  tags     = local.tags[each.key]
}

resource "azuread_group" "contributor" {
  for_each         = var.resource_groups
  display_name     = "DTS Innovation ${var.env} ${local.rg_names[each.key]} Contributor SC"
  security_enabled = true
  description      = "Allows contributor access to the ${local.rg_names[each.key]} resource group in DTS-INNOVATION-PROD. Access should be gained via an access package."
}

resource "azuread_group" "contributor_eligible" {
  for_each         = var.resource_groups
  display_name     = "DTS Innovation ${var.env} ${local.rg_names[each.key]} Contributor Eligible SC"
  security_enabled = true
  description      = "Allows users to request contributor access to the ${local.rg_names[each.key]} resource group in DTS-INNOVATION-PROD."
}

resource "azuread_group_member" "sub_readers" {
  for_each         = var.resource_groups
  group_object_id  = data.azuread_group.sub_reader.object_id
  member_object_id = azuread_group.contributor_eligible[each.key].object_id
}

resource "azuread_group_member" "contributor" {
  for_each         = var.resource_groups
  group_object_id  = data.azuread_group.sub_contributor.object_id
  member_object_id = azuread_group.contributor[each.key].object_id
}

//define budget with alert to owner_email.
