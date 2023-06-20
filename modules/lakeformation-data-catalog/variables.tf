variable "catalog" {
  description = "(Optional) The ID of the Data Catalog to configure. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
}

variable "admins" {
  description = <<EOF
  (Optional) A set of ARNs of AWS Lake Formation principals. Administrators can view all metadata in the AWS Glue Data Catalog. They can also grant and revoke permissions on data resources to principals, including themselves. Valid values are following:
  - IAM Users and Roles
  - Active Directory
  - Amazon QuickSight Users and Groups
  - Federated Users
  EOF
  type        = set(string)
  default     = []
  nullable    = false
}

variable "lf_tags" {
  description = "(Optional) LF-Tags have a key and one or more values that can be associated with data catalog resources. Tables automatically inherit from database LF-Tags, and columns inherit from table LF-Tags. Each key must have at least one value. The maximum number of values permitted is 15."
  type        = map(set(string))
  default     = {}
  nullable    = false
}
