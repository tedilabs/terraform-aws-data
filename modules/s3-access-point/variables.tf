variable "name" {
  description = "(Required) A name you want to assign to this access point. Access point names must be unique within the account for this Region."
  type        = string
}

variable "bucket" {
  description = <<EOF
  (Required) A configuration of S3 bucket to associate with this access point.
    (Required) `name` - A name of an AWS Partition S3 Bucket or the Amazon Resource Name (ARN) of S3 on Outposts Bucket that you want to associate this access point with.
    (Optional) `account_id` - The AWS account ID associated with the S3 bucket associated with this access point. Only used for creating an access point by using a bucket in a different AWS account.
  EOF
  type = object({
    name       = string
    account_id = optional(string)
  })
  nullable = false
}

variable "network_origin" {
  description = "(Optional) Indicates whether this access point allows access from the public Internet. Valid Values are `VPC` (the access point doesn't allow access from the public Internet) and `INTERNET` (the access point allows access from the public Internet, subject to the access point and bucket access policies). Defaults to `INTERNET`."
  type        = string
  default     = "INTERNET"
  nullable    = false

  validation {
    condition     = contains(["INTERNET", "VPC"], var.network_origin)
    error_message = "Valid values for `network_origin` are `INTERNET`, `VPC`."
  }
}

variable "vpc_id" {
  description = "(Optional) The VPC ID to be only allowed connections to this access point. Only required if `network_origin` is `VPC`."
  type        = string
  default     = null
}

variable "policy" {
  description = "(Optional) A valid policy JSON document that specifies the policy for this access point."
  type        = string
  default     = ""
  nullable    = false
}

variable "block_public_access" {
  description = <<EOF
  (Optional) A configurations of Block Public Access for the S3 access point. Public access is granted to buckets and objects through access control lists (ACLs), bucket policies, access point policies, or all. These settings apply only to this Access Point. Before applying these settings, ensure that your applications will work correctly without public access. These settings can’t be edited after the Access Point is created.
    (Optional) `enabled` - Whether to block all public access to S3 access point. Defaults to `true`.
    (Optional) `block_public_acls_enabled` - Block new public ACLs and uploading public objects if true. Always enabled if `block_public_access.enabled` is `true`.
    (Optional) `ignore_public_acls_enabled` - Retroactively remove public access granted through public ACLs. Always enabled if `block_public_access.enabled` is `true`.
    (Optional) `block_public_policy_enabled` - Block new public bucket policies. Always enabled if `block_public_access.enabled` is `true`.
    (Optional) `restrict_public_buckets_enabled` - Retroactivley block public and cross-account access if bucket has public policies. Always enabled if `block_public_access.enabled` is `true`.
  EOF
  type = object({
    enabled                         = optional(bool, true)
    block_public_acls_enabled       = optional(bool, false)
    ignore_public_acls_enabled      = optional(bool, false)
    block_public_policy_enabled     = optional(bool, false)
    restrict_public_buckets_enabled = optional(bool, false)
  })
  default  = {}
  nullable = false
}
