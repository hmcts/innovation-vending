variable "resource_groups" {
  type = map(object({
    end_date         = string
    team_entra_group = string
    location         = optional(string, "uksouth")
  }))
  default = {}
}

variable "tenant_id" {
  sensitive = true
  default   = ""
}

variable "client_id" {
  sensitive = true
  default   = ""
}

variable "client_secret" {
  sensitive = true
  default   = ""
}
