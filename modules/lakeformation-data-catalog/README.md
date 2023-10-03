# lakeformation-data-catalog

This module creates following resources.

- `aws_lakeformation_data_lake_settings`
- `aws_lakeformation_lf_tag` (optional)

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lakeformation_data_lake_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_data_lake_settings) | resource |
| [aws_lakeformation_lf_tag.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lakeformation_lf_tag) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admins"></a> [admins](#input\_admins) | (Optional) A set of ARNs of AWS Lake Formation principals. Administrators can view all metadata in the AWS Glue Data Catalog. They can also grant and revoke permissions on data resources to principals, including themselves. Valid values are following:<br>  - IAM Users and Roles<br>  - Active Directory<br>  - Amazon QuickSight Users and Groups<br>  - Federated Users | `set(string)` | `[]` | no |
| <a name="input_catalog"></a> [catalog](#input\_catalog) | (Optional) The ID of the Data Catalog to configure. If omitted, this defaults to the AWS Account ID. | `string` | `null` | no |
| <a name="input_lf_tags"></a> [lf\_tags](#input\_lf\_tags) | (Optional) LF-Tags have a key and one or more values that can be associated with data catalog resources. Tables automatically inherit from database LF-Tags, and columns inherit from table LF-Tags. Each key must have at least one value. The maximum number of values permitted is 15. | `map(set(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_catalog"></a> [catalog](#output\_catalog) | The ID of the Data Catalog. |
| <a name="output_lf_tags"></a> [lf\_tags](#output\_lf\_tags) | LF-Tags have a key and one or more values that can be associated with data catalog resources. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
