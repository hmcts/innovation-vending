resource "azurerm_consumption_budget_resource_group" "this" {
  for_each          = local.resource_groups
  name              = local.rg_names[each.key]
  resource_group_id = azurerm_resource_group.this[each.key].id

  amount     = each.value.budget
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", time_static.creation_datetime[each.key].rfc3339)
  }

  notification {
    enabled        = true
    threshold      = 90.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [each.value.owner.email]
  }

  notification {
    enabled        = true
    threshold      = 100.0
    operator       = "EqualTo"
    threshold_type = "Actual"

    contact_emails = [each.value.owner.email]
  }
}
