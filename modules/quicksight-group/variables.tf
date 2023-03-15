variable "name" {
  description = "(Required) A name for the QuickSight group."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) A description for the QuickSight group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "namespace" {
  description = "(Optional) The namespace that you want the group to be a part of."
  type        = string
  default     = "default"
  nullable    = false
}

variable "members" {
  description = "(Optional) A set of user names that you want to add to the group membership."
  type        = set(string)
  default     = []
  nullable    = false
}
