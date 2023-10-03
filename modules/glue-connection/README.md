# glue-connection

This module creates following resources.

- `aws_glue_connection`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.65 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.19.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [aws_glue_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_connection) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) The name of the Glue connection. | `string` | n/a | yes |
| <a name="input_properties"></a> [properties](#input\_properties) | (Optional) A map of key-value pairs used as parameters for this connection.<br>  ## `JDBC`<br>  - JDBC Connections use the following parameters.<br>    (Required) All of (`HOST`, `PORT`, `JDBC_ENGINE`) or `JDBC_CONNECTION_URL`.<br>    (Required) All of (`USERNAME`, `PASSWORD`) or `SECRET_ID`.<br>    (Optional) `JDBC_ENFORCE_SSL`, `CUSTOM_JDBC_CERT`, `CUSTOM_JDBC_CERT_STRING`, `SKIP_CUSTOM_JDBC_CERT_VALIDATION`<br><br>  ## `KAFKA`<br>  - KAFKA Connections use the following parameters.<br>    (Required) `KAFKA_BOOTSTRAP_SERVERS`.<br>    (Optional) `KAFKA_SSL_ENABLED`, `KAFKA_CUSTOM_CERT`, `KAFKA_SKIP_CUSTOM_CERT_VALIDATION`.<br>    (Optional) `KAFKA_CLIENT_KEYSTORE`, `KAFKA_CLIENT_KEYSTORE_PASSWORD`, `KAFKA_CLIENT_KEY_PASSWORD`, `ENCRYPTED_KAFKA_CLIENT_KEYSTORE_PASSWORD`, `ENCRYPTED_KAFKA_CLIENT_KEY_PASSWORD`<br>    (Optional) `KAFKA_SASL_MECHANISM` - Valid values are `SCRAM-SHA-512`, `GSSAPI`, or `AWS_MSK_IAM`.<br>    (Optional) `KAFKA_SASL_SCRAM_USERNAME`, `KAFKA_SASL_SCRAM_PASSWORD`, `ENCRYPTED_KAFKA_SASL_SCRAM_PASSWORD` - Parameters are used to configure SASL/SCRAM-SHA-512 authentication.<br>    (Optional) `KAFKA_SASL_GSSAPI_KEYTAB`, `KAFKA_SASL_GSSAPI_KRB5_CONF`, `KAFKA_SASL_GSSAPI_SERVICE`, `KAFKA_SASL_GSSAPI_PRINCIPAL` - Parameters are used to configure SASL/GSSAPI authentication.<br><br>  ## `MONGODB`<br>  - MONGODB Connections use the following parameters.<br>    (Required) `CONNECTION_URL`.<br>    (Required) All of (`USERNAME`, `PASSWORD`) or `SECRET_ID`.<br><br>  ## `NETWORK`<br>  - NETWORK Connections do not require parameters. Instead, provide a `physical_connection_requirements`.<br><br>  ## `MARKETPLACE`<br>  - MARKETPLACE Connections use the following parameters.<br>    (Required) `CONNECTOR_TYPE`, `CONNECTOR_URL`, `CONNECTOR_CLASS_NAME`, `CONNECTION_URL`.<br>    (Required) All of (`USERNAME`, `PASSWORD`) or `SECRET_ID`. Only required if `CONNECTOR_TYPE` is `JDBC`.<br><br>  ## `CUSTOM`<br>  - Use configuration settings contained in a custom connector to read from and write to data stores that are not natively supported by Glue. | `map(string)` | n/a | yes |
| <a name="input_catalog"></a> [catalog](#input\_catalog) | (Optional) The ID of the Data Catalog in which to create the connection. If omitted, this defaults to the AWS Account ID. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) The description of the connection. Can be up to 2048 characters long. | `string` | `"Managed by Terraform."` | no |
| <a name="input_match_criteria"></a> [match\_criteria](#input\_match\_criteria) | (Optional) A list of criteria that can be used in selecting this connection. | `list(string)` | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_resource_group_description"></a> [resource\_group\_description](#input\_resource\_group\_description) | (Optional) The description of Resource Group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_resource_group_enabled"></a> [resource\_group\_enabled](#input\_resource\_group\_enabled) | (Optional) Whether to create Resource Group to find and group AWS resources which are created by this module. | `bool` | `true` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | (Optional) The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | (Optional) The type of the connection. Valid values are `CUSTOM`, `JDBC`, `KAFKA`, `MARKETPLACE`, `MONGODB`, and `NETWORK`. Defaults to `JBDC`. | `string` | `"JDBC"` | no |
| <a name="input_vpc_association"></a> [vpc\_association](#input\_vpc\_association) | (Optional) A configuration for additional VPC association of the Glue connection when your AWS Glue job needs to run on Amazon Elastic Compute Cloud (EC2) instances in a virtual private cloud (VPC) subnet. `vpc_association` as defined below.<br>    (Optional) `enabled` - Whether to associate Glue connection to VPC subnet.<br>    (Optional) `subnet` - The subnet ID used by the connection.<br>    (Optional) `security_groups` - A list of IDs of security groups to allow access to the data store in your VPC subnet. Security groups are associated to the ENI attached to your subnet. You must choose at least one security group with a self-referencing inbound rule for all TCP ports. | <pre>object({<br>    enabled         = optional(bool, false)<br>    subnet          = optional(string)<br>    security_groups = optional(set(string), [])<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the Glue connection. |
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Glue Catalog. |
| <a name="output_description"></a> [description](#output\_description) | The description of the Glue connection. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Glue connection. |
| <a name="output_match_criteria"></a> [match\_criteria](#output\_match\_criteria) | A list of criteria that can be used in selecting this connection. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Glue connection. |
| <a name="output_properties"></a> [properties](#output\_properties) | A map of key-value pairs used as parameters for this connection. |
| <a name="output_type"></a> [type](#output\_type) | The type of the connection. |
| <a name="output_vpc_association"></a> [vpc\_association](#output\_vpc\_association) | A configuration for additional VPC association of the Glue connection when your AWS Glue job needs to run on Amazon Elastic Compute Cloud (EC2) instances in a virtual private cloud (VPC) subnet. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
