variable "resource_groups" {
  type = map(object({
    end_date = string
    owner = object({
      team_name = optional(string)
      name      = string
      email     = string
    })
    location = optional(string, "uksouth")
    budget   = optional(number, 1000)
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
