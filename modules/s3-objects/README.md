# s3-objects

This module creates following resources.

- `aws_s3_object`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.23 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.57.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | tedilabs/misc/aws//modules/resource-group | ~> 0.12.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Required) The name of the S3 bucket to put the objects in. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | (Required) Desired name for the module instance. Used for the module metadata and the Resource Group name. | `string` | n/a | yes |
| <a name="input_directories"></a> [directories](#input\_directories) | (Optional) A list of local directories to sync to the S3 bucket. All files matched in each directory are uploaded as individual objects. Objects defined in `files` take precedence over objects from `directories` when the object keys conflict. A key collision between two directories results in a plan-time error. Each value of `directories` as defined below.<br/>    (Required) `path` - The path to a local directory to sync to the S3 bucket.<br/>    (Optional) `key_prefix` - The key prefix to prepend to each object key. The object key is built as `key_prefix` followed by the file path relative to `path`. Defaults to an empty string (`""`).<br/>    (Optional) `include_patterns` - A list of glob patterns to include files in the directory. Defaults to `["**"]` (all files).<br/>    (Optional) `exclude_patterns` - A list of glob patterns to exclude files from the matched files. Defaults to `[]`.<br/>    (Optional) `storage_class` - The storage class of the objects. Valid values are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR` and `EXPRESS_ONEZONE`. Defaults to `STANDARD`.<br/>    (Optional) `cache_control` - The caching behavior along the request/reply chain for the objects.<br/>    (Optional) `metadata` - A map of keys/values to provision metadata for the objects. Metadata keys are always converted to lowercase by AWS.<br/>    (Optional) `force_destroy` - Whether to allow the objects to be deleted while the bucket has a legal hold on the objects. Defaults to `false`.<br/>    (Optional) `tags` - A map of tags to add to the objects. | <pre>list(object({<br/>    path             = string<br/>    key_prefix       = optional(string, "")<br/>    include_patterns = optional(list(string), ["**"])<br/>    exclude_patterns = optional(list(string), [])<br/><br/>    storage_class = optional(string, "STANDARD")<br/>    cache_control = optional(string)<br/>    metadata      = optional(map(string), {})<br/><br/>    force_destroy = optional(bool, false)<br/>    tags          = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_files"></a> [files](#input\_files) | (Optional) A list of files to upload to the S3 bucket. Each file is uploaded as an object from a local file or an inline content. Each object key takes precedence over objects from `directories` when the object keys conflict. Each value of `files` as defined below.<br/>    (Required) `key` - The full key (path) of the object in the S3 bucket. The key must be unique within `files`.<br/>    (Optional) `source` - The path to a local file that will be uploaded as the object content. Exactly one of `source` or `content` must be provided. The object is automatically re-uploaded when the content of the file changes.<br/>    (Optional) `content` - The literal string value to use as the object content. Exactly one of `source` or `content` must be provided.<br/>    (Optional) `content_type` - The standard MIME type of the object content. If not provided, the content type is inferred from the file extension of `key`. Defaults to `application/octet-stream` if the extension is unknown.<br/>    (Optional) `storage_class` - The storage class of the object. Valid values are `STANDARD`, `REDUCED_REDUNDANCY`, `STANDARD_IA`, `ONEZONE_IA`, `INTELLIGENT_TIERING`, `GLACIER`, `DEEP_ARCHIVE`, `GLACIER_IR` and `EXPRESS_ONEZONE`. Defaults to `STANDARD`.<br/>    (Optional) `cache_control` - The caching behavior along the request/reply chain. Read [w3c cache\_control](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9) for further details.<br/>    (Optional) `content_disposition` - The presentational information for the object. Read [w3c content\_disposition](http://www.w3.org/Protocols/rfc2616/rfc2616-sec19.html#sec19.5.1) for further details.<br/>    (Optional) `content_encoding` - The content encodings that have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the `content_type`.<br/>    (Optional) `content_language` - The language the object content is in.<br/>    (Optional) `website_redirect` - The target URL for website redirect.<br/>    (Optional) `metadata` - A map of keys/values to provision metadata. Metadata keys are always converted to lowercase by AWS.<br/>    (Optional) `force_destroy` - Whether to allow the object to be deleted while the bucket has a legal hold on the object. Defaults to `false`.<br/>    (Optional) `tags` - A map of tags to add to the object. | <pre>list(object({<br/>    key = string<br/><br/>    source       = optional(string)<br/>    content      = optional(string)<br/>    content_type = optional(string)<br/><br/>    storage_class       = optional(string, "STANDARD")<br/>    cache_control       = optional(string)<br/>    content_disposition = optional(string)<br/>    content_encoding    = optional(string)<br/>    content_language    = optional(string)<br/>    website_redirect    = optional(string)<br/>    metadata            = optional(map(string), {})<br/><br/>    force_destroy = optional(bool, false)<br/>    tags          = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_module_tags_enabled"></a> [module\_tags\_enabled](#input\_module\_tags\_enabled) | (Optional) Whether to create AWS Resource Tags for the module informations. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) The region in which to create the module resources. If not provided, the module resources will be created in the provider's configured region. | `string` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | (Optional) A configurations of Resource Group for this module. `resource_group` as defined below.<br/>    (Optional) `enabled` - Whether to create Resource Group to find and group AWS resources which are created by this module. Defaults to `true`.<br/>    (Optional) `name` - The name of Resource Group. A Resource Group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with `AWS` or `aws`. If not provided, a name will be generated using the module name and instance name.<br/>    (Optional) `description` - The description of Resource Group. Defaults to `Managed by Terraform.`. | <pre>object({<br/>    enabled     = optional(bool, true)<br/>    name        = optional(string, "")<br/>    description = optional(string, "Managed by Terraform.")<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A map of tags to add to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The name of the S3 bucket which the objects are stored in. |
| <a name="output_name"></a> [name](#output\_name) | The name of this module instance. |
| <a name="output_objects"></a> [objects](#output\_objects) | The objects uploaded to the S3 bucket by the object key. |
| <a name="output_region"></a> [region](#output\_region) | The AWS region this module resources resides in. |
| <a name="output_resource_group"></a> [resource\_group](#output\_resource\_group) | The resource group created to manage resources in this module. |
<!-- END_TF_DOCS -->
