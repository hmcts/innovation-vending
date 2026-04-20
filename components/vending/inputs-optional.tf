variable "resource_groups" {
  type = map(object({
    end_date         = string
    team_entra_group = string
    location         = optional(string, "uksouth")
  }))
  default = {}

}
