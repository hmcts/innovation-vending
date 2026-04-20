resource "azuread_access_package_catalog" "innovation" {
  display_name       = "DTS Innovation Contributor Access"
  description        = "Catalog for requesting contributor access to Innovation resource groups in DTS-INNOVATION-PROD."
  published          = true
  externally_visible = false
}

resource "azuread_access_package_resource_catalog_association" "contributor" {
  for_each               = local.resource_groups
  catalog_id             = azuread_access_package_catalog.innovation.id
  resource_origin_id     = azuread_group.contributor[each.key].object_id
  resource_origin_system = "AadGroup"
}

resource "azuread_access_package" "contributor" {
  for_each     = local.resource_groups
  display_name = "DTS Innovation ${each.key} RG Contributor"
  description  = "Grants contributor access to the ${local.rg_names[each.key]} resource group in DTS-INNOVATION-PROD."
  catalog_id   = azuread_access_package_catalog.innovation.id
}

resource "azuread_access_package_resource_package_association" "contributor" {
  for_each                        = local.resource_groups
  access_package_id               = azuread_access_package.contributor[each.key].id
  catalog_resource_association_id = azuread_access_package_resource_catalog_association.contributor[each.key].id
}

resource "azuread_access_package_assignment_policy" "self_approval" {
  for_each          = local.resource_groups
  access_package_id = azuread_access_package.contributor[each.key].id
  display_name      = "Self Approval - 8 Hours"
  description       = "Self-approval policy for contributor access to ${local.rg_names[each.key]}. Access lasts 8 hours."
  duration_in_days  = 1
  extension_enabled = false

  approval_settings {
    approval_required = false
  }

  requestor_settings {
    requests_accepted = true
    scope_type        = "SpecificDirectorySubjects"

    requestor {
      object_id    = azuread_group.contributor_eligible[each.key].object_id
      subject_type = "groupMembers"
    }
  }
}
