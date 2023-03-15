# quicksight-group

This module creates following resources.

- `aws_quicksight_group`
- `aws_quicksight_group_membership` (optional)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.58 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.58.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_quicksight_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_group) | resource |
| [aws_quicksight_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/quicksight_group_membership) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | (Required) A name for the QuickSight group. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) A description for the QuickSight group. | `string` | `"Managed by Terraform."` | no |
| <a name="input_members"></a> [members](#input\_members) | (Optional) A set of user names that you want to add to the group membership. | `set(string)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | (Optional) The namespace that you want the group to be a part of. | `string` | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the QuickSight group. |
| <a name="output_description"></a> [description](#output\_description) | The description of the QuickSight group. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the QuickSight group. |
| <a name="output_members"></a> [members](#output\_members) | A set of user names that you want to add to the group membership. |
| <a name="output_name"></a> [name](#output\_name) | The name of the QuickSight group. |
| <a name="output_namespace"></a> [namespace](#output\_namespace) | The namespace that the group belongs to. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
