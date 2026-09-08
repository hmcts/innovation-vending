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

resource "azurerm_role_assignment" "contributor" {
  for_each             = var.resource_groups
  scope                = azurerm_resource_group.this[each.key].id
  role_definition_name = "Contributor"
  principal_id         = azuread_group.contributor[each.key].object_id
}

locals {
  additional_role_assignments = {
    for assignment in flatten([
      for resource_group_key, resource_group in var.resource_groups : [
        for role_name in resource_group.additional_roles : {
          resource_group_key = resource_group_key
          role_name          = role_name
        }
      ]
    ]) : "${assignment.resource_group_key}|${assignment.role_name}" => assignment
  }
}

resource "azurerm_role_assignment" "additional" {
  for_each = local.additional_role_assignments

  scope                = azurerm_resource_group.this[each.value.resource_group_key].id
  role_definition_name = each.value.role_name
  principal_id         = azuread_group.contributor[each.value.resource_group_key].object_id
}
