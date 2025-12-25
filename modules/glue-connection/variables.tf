variable "region" {
  description = "(Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region."
  type        = string
  default     = null
  nullable    = true
}

variable "catalog" {
  description = "(Optional) The ID of the Data Catalog in which to create the connection. If omitted, this defaults to the AWS Account ID."
  type        = string
  default     = null
  nullable    = true
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
  description = <<EOF
  (Required) The type of the connection. Valid values are `JDBC`, `SFTP`, `MONGODB`, `KAFKA`, `NETWORK`, `MARKETPLACE`, `CUSTOM`, `SALESFORCE`, `VIEW_VALIDATION_REDSHIFT`, `VIEW_VALIDATION_ATHENA`, `GOOGLEADS`, `GOOGLESHEETS`, `GOOGLEANALYTICS4`, `SERVICENOW`, `MARKETO`, `SAPODATA`, `ZENDESK`, `JIRACLOUD`, `NETSUITEERP`, `HUBSPOT`, `FACEBOOKADS`, `INSTAGRAMADS`, `ZOHOCRM`, `SALESFORCEPARDOT`, `SALESFORCEMARKETINGCLOUD`, `ADOBEANALYTICS`, `SLACK`, `LINKEDIN`, `MIXPANEL`, `ASANA`, `STRIPE`, `SMARTSHEET`, `DATADOG`, `WOOCOMMERCE`, `INTERCOM`, `SNAPCHATADS`, `PAYPAL`, `QUICKBOOKS`, `FACEBOOKPAGEINSIGHTS`, `FRESHDESK`, `TWILIO`, `DOCUSIGNMONITOR`, `FRESHSALES`, `ZOOM`, `GOOGLESEARCHCONSOLE`, `SALESFORCECOMMERCECLOUD`, `SAPCONCUR`, `DYNATRACE`, `MICROSOFTDYNAMIC365FINANCEANDOPS`, `MICROSOFTTEAMS`, `BLACKBAUDRAISEREDGENXT`, `MAILCHIMP`, `GITLAB`, `PENDO`, `PRODUCTBOARD`, `CIRCLECI`, `PIPEDIVE`, `SENDGRID`, `AZURECOSMOS`, `AZURESQL`, `BIGQUERY`, `BLACKBAUD`, `CLOUDERAHIVE`, `CLOUDERAIMPALA`, `CLOUDWATCH`, `CLOUDWATCHMETRICS`, `CMDB`, `DATALAKEGEN2`, `DB2`, `DB2AS400`, `DOCUMENTDB`, `DOMO`, `DYNAMODB`, `GOOGLECLOUDSTORAGE`, `HBASE`, `KUSTOMER`, `MICROSOFTDYNAMICS365CRM`, `MONDAY`, `MYSQL`, `OKTA`, `OPENSEARCH`, `ORACLE`, `PIPEDRIVE`, `POSTGRESQL`, `SAPHANA`, `SQLSERVER`, `SYNAPSE`, `TERADATA`, `TERADATANOS`, `TIMESTREAM`, `TPCDS`, `VERTICA`.
  EOF
  type        = string
  nullable    = false
}

variable "properties" {
  description = <<EOF
  (Optional) A map of key-value pairs used as parameters for this connection. Valid property keys are `HOST`, `PORT`, `USERNAME`, `PASSWORD`, `ENCRYPTED_PASSWORD`, `JDBC_DRIVER_JAR_URI`, `JDBC_DRIVER_CLASS_NAME`, `JDBC_ENGINE`, `JDBC_ENGINE_VERSION`, `CONFIG_FILES`, `INSTANCE_ID`, `JDBC_CONNECTION_URL`, `JDBC_ENFORCE_SSL`, `CUSTOM_JDBC_CERT`, `SKIP_CUSTOM_JDBC_CERT_VALIDATION`, `CUSTOM_JDBC_CERT_STRING`, `CONNECTION_URL`, `KAFKA_BOOTSTRAP_SERVERS`, `KAFKA_SSL_ENABLED`, `KAFKA_CUSTOM_CERT`, `KAFKA_SKIP_CUSTOM_CERT_VALIDATION`, `KAFKA_CLIENT_KEYSTORE`, `KAFKA_CLIENT_KEYSTORE_PASSWORD`, `KAFKA_CLIENT_KEY_PASSWORD`, `ENCRYPTED_KAFKA_CLIENT_KEYSTORE_PASSWORD`, `ENCRYPTED_KAFKA_CLIENT_KEY_PASSWORD`, `KAFKA_SASL_MECHANISM`, `KAFKA_SASL_PLAIN_USERNAME`, `KAFKA_SASL_PLAIN_PASSWORD`, `ENCRYPTED_KAFKA_SASL_PLAIN_PASSWORD`, `KAFKA_SASL_SCRAM_USERNAME`, `KAFKA_SASL_SCRAM_PASSWORD`, `KAFKA_SASL_SCRAM_SECRETS_ARN`, `ENCRYPTED_KAFKA_SASL_SCRAM_PASSWORD`, `KAFKA_SASL_GSSAPI_KEYTAB`, `KAFKA_SASL_GSSAPI_KRB5_CONF`, `KAFKA_SASL_GSSAPI_SERVICE`, `KAFKA_SASL_GSSAPI_PRINCIPAL`, `SECRET_ID`, `CONNECTOR_URL`, `CONNECTOR_TYPE`, `CONNECTOR_CLASS_NAME`, `ENDPOINT`, `ENDPOINT_TYPE`, `ROLE_ARN`, `REGION`, `WORKGROUP_NAME`, `CLUSTER_IDENTIFIER`, `DATABASE`.

  The following are the specific parameters used for each connection type:

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
  - NETWORK Connections do not require parameters. Instead, provide a `vpc_association`.

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

variable "athena_properties" {
  description = <<EOF
  (Optional) A map of key-value pairs used as connection properties for Athena compute environment.
  EOF
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "match_criteria" {
  description = "(Optional) A list of criteria that can be used in selecting this connection."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "vpc_association" {
  description = <<EOF
  (Optional) A configuration for additional VPC association of the Glue connection when your AWS Glue job needs to run on Amazon Elastic Compute Cloud (EC2) instances in a virtual private cloud (VPC) subnet. `vpc_association` as defined below.
    (Optional) `enabled` - Whether to associate Glue connection to VPC subnet.
    (Optional) `subnet` - The subnet ID used by the connection.

    (Optional) `default_security_group` - The configuration of the default security group for the Glue connection. `default_security_group` block as defined below.
      (Optional) `enabled` - Whether to use the default security group. Defaults to `true`.
      (Optional) `name` - The name of the default security group. If not provided, the Glue connection name is used for the name of security group.
      (Optional) `description` - The description of the default security group.
      (Optional) `ingress_rules` - A list of ingress rules in a security group. Defaults to `[]`. Each block of `ingress_rules` as defined below.
        (Required) `id` - The ID of the ingress rule. This value is only used internally within Terraform code.
        (Optional) `description` - The description of the rule.
        (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
        (Required) `from_port` - The start of port range for the protocols.
        (Required) `to_port` - The end of port range for the protocols.
        (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
        (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
        (Optional) `prefix_lists` - The prefix list IDs to allow.
        (Optional) `security_groups` - The source security group IDs to allow.
        (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
      (Optional) `egress_rules` - A list of egress rules in a security group. Defaults to `[]`. Each block of `egress_rules` as defined below.
        (Required) `id` - The ID of the egress rule. This value is only used internally within Terraform code.
        (Optional) `description` - The description of the rule.
        (Required) `protocol` - The protocol to match. Note that if `protocol` is set to `-1`, it translates to all protocols, all port ranges, and `from_port` and `to_port` values should not be defined.
        (Required) `from_port` - The start of port range for the protocols.
        (Required) `to_port` - The end of port range for the protocols.
        (Optional) `ipv4_cidrs` - The IPv4 network ranges to allow, in CIDR notation.
        (Optional) `ipv6_cidrs` - The IPv6 network ranges to allow, in CIDR notation.
        (Optional) `prefix_lists` - The prefix list IDs to allow.
        (Optional) `security_groups` - The source security group IDs to allow.
        (Optional) `self` - Whether the security group itself will be added as a source to this ingress rule.
    (Optional) `security_groups` - A set of IDs of security groups to allow access to the data store in your VPC subnet. Security groups are associated to the ENI attached to your subnet. You must choose at least one security group with a self-referencing inbound rule for all TCP ports.
  EOF
  type = object({
    enabled = optional(bool, false)
    subnet  = optional(string)
    default_security_group = optional(object({
      enabled     = optional(bool, true)
      name        = optional(string)
      description = optional(string, "Managed by Terraform.")
      ingress_rules = optional(
        list(object({
          id              = string
          description     = optional(string, "Managed by Terraform.")
          protocol        = string
          from_port       = number
          to_port         = number
          ipv4_cidrs      = optional(list(string), [])
          ipv6_cidrs      = optional(list(string), [])
          prefix_lists    = optional(list(string), [])
          security_groups = optional(list(string), [])
          self            = optional(bool, false)
        })),
        []
      )
      egress_rules = optional(
        list(object({
          id              = string
          description     = optional(string, "Managed by Terraform.")
          protocol        = string
          from_port       = number
          to_port         = number
          ipv4_cidrs      = optional(list(string), [])
          ipv6_cidrs      = optional(list(string), [])
          prefix_lists    = optional(list(string), [])
          security_groups = optional(list(string), [])
          self            = optional(bool, false)
        })),
        []
      )
    }), {})
    security_groups = optional(set(string), [])
  })
  default  = {}
  nullable = false
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

variable "resource_group" {
  description = <<EOF
  (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.
    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.
    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.
    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`.
  EOF
  type = object({
    enabled     = optional(bool, true)
    name        = optional(string, "")
    description = optional(string, "Managed by Terraform.")
  })
  default  = {}
  nullable = false
}
