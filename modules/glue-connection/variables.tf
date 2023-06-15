variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to create the connection. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
}

variable "name" {
  description = "(Required) The name of the Glue connection."
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) The description of the connection. Can be up to 2048 characters long."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}

variable "type" {
  description = "(Optional) The type of the connection. Valid values are `CUSTOM`, `JDBC`, `KAFKA`, `MARKETPLACE`, `MONGODB`, and `NETWORK`. Defaults to `JBDC`."
  type        = string
  default     = "JDBC"
  nullable    = false
}

variable "properties" {
  description = <<EOF
  (Optional) A map of key-value pairs used as parameters for this connection.
  ## `JDBC`
  - JDBC Connections use the following parameters.
    (Required) All of (`HOST`, `PORT`, `JDBC_ENGINE`) or `JDBC_CONNECTION_URL`.
    (Required) All of (`USERNAME`, `PASSWORD`) or `SECRET_ID`.
    (Optional) `JDBC_ENFORCE_SSL`, `CUSTOM_JDBC_CERT`, `CUSTOM_JDBC_CERT_STRING`, `SKIP_CUSTOM_JDBC_CERT_VALIDATION`

  ## `KAFKA`
  - KAFKA Connections use the following parameters.
    (Required) `KAFKA_BOOTSTRAP_SERVERS`.
    (Optional) `KAFKA_SSL_ENABLED`, `KAFKA_CUSTOM_CERT`, `KAFKA_SKIP_CUSTOM_CERT_VALIDATION`.
    (Optional) `KAFKA_CLIENT_KEYSTORE`, `KAFKA_CLIENT_KEYSTORE_PASSWORD`, `KAFKA_CLIENT_KEY_PASSWORD`, `ENCRYPTED_KAFKA_CLIENT_KEYSTORE_PASSWORD`, `ENCRYPTED_KAFKA_CLIENT_KEY_PASSWORD`
    (Optional) `KAFKA_SASL_MECHANISM` - Valid values are `SCRAM-SHA-512`, `GSSAPI`, or `AWS_MSK_IAM`.
    (Optional) `KAFKA_SASL_SCRAM_USERNAME`, `KAFKA_SASL_SCRAM_PASSWORD`, `ENCRYPTED_KAFKA_SASL_SCRAM_PASSWORD` - Parameters are used to configure SASL/SCRAM-SHA-512 authentication.
    (Optional) `KAFKA_SASL_GSSAPI_KEYTAB`, `KAFKA_SASL_GSSAPI_KRB5_CONF`, `KAFKA_SASL_GSSAPI_SERVICE`, `KAFKA_SASL_GSSAPI_PRINCIPAL` - Parameters are used to configure SASL/GSSAPI authentication.

  ## `MONGODB`
  - MONGODB Connections use the following parameters.
    (Required) `CONNECTION_URL`.
    (Required) All of (`USERNAME`, `PASSWORD`) or `SECRET_ID`.

  ## `NETWORK`
  - NETWORK Connections do not require parameters. Instead, provide a `physical_connection_requirements`.

  ## `MARKETPLACE`
  - MARKETPLACE Connections use the following parameters.
    (Required) `CONNECTOR_TYPE`, `CONNECTOR_URL`, `CONNECTOR_CLASS_NAME`, `CONNECTION_URL`.
    (Required) All of (`USERNAME`, `PASSWORD`) or `SECRET_ID`. Only required if `CONNECTOR_TYPE` is `JDBC`.

  ## `CUSTOM`
  - Use configuration settings contained in a custom connector to read from and write to data stores that are not natively supported by Glue.
  EOF
  type        = map(string)
  nullable    = false
}

variable "vpc_association" {
  description = <<EOF
  (Optional) A configuration for additional VPC association of the Glue connection when your AWS Glue job needs to run on Amazon Elastic Compute Cloud (EC2) instances in a virtual private cloud (VPC) subnet. `vpc_association` as defined below.
    (Optional) `enabled` - Whether to associate Glue connection to VPC subnet.
    (Optional) `subnet` - The subnet ID used by the connection.
    (Optional) `security_groups` - A list of IDs of security groups to allow access to the data store in your VPC subnet. Security groups are associated to the ENI attached to your subnet. You must choose at least one security group with a self-referencing inbound rule for all TCP ports.
  EOF
  type = object({
    enabled         = optional(bool, false)
    subnet          = optional(string)
    security_groups = optional(set(string), [])
  })
  default  = {}
  nullable = false
}

variable "match_criteria" {
  description = "(Optional) A list of criteria that can be used in selecting this connection."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "tags" {
  description = "(Optional) A map of tags to add to all resources."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "module_tags_enabled" {
  description = "(Optional) Whether to create AWS Resource Tags for the module informations."
  type        = bool
  default     = true
  nullable    = false
}


###################################################
# Resource Group
###################################################

variable "resource_group_enabled" {
  description = "(Optional) Whether to create Resource Group to find and group AWS resources which are created by this module."
  type        = bool
  default     = true
  nullable    = false
}

variable "resource_group_name" {
  description = "(Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`."
  type        = string
  default     = ""
  nullable    = false
}

variable "resource_group_description" {
  description = "(Optional) The description of Resource Group."
  type        = string
  default     = "Managed by Terraform."
  nullable    = false
}
