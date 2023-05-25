# terraform-aws-data

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-data?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-data?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates data related resources on AWS.

- [athena-data-catalog](./modules/athena-data-catalog)
- [athena-workgroup](./modules/athena-workgroup)
- [quicksight-folder](./modules/quicksight-folder)
- [quicksight-group](./modules/quicksight-group)
- [quicksight-namespace](./modules/quicksight-namespace)
- [s3-access-point](./modules/s3-access-point)
- [s3-bucket](./modules/s3-bucket)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-data) were written to manage the following AWS Services with Terraform.

- **AWS Athena**
  - Data Catalog
  - Workgroup
- **AWS QuickSight**
  - Folder
  - Group & Group Membership
  - Namespace
- **AWS S3**
  - S3 Bucket
  - S3 Access Point


## Examples

### QuickSight

- [QuickSight User and Group](./examples/quicksight-user-and-group)
- [QuickSight Assets](./examples/quicksight-assets)

### S3 Bucket

- [Full S3 Bucket](./examples/s3-bucket-full)
- [S3 Bucket with Access Logging](./examples/s3-bucket-access-logging)
- [S3 Bucket with Server-Side Encryption](./examples/s3-bucket-encryption)
- [S3 Bucket with Lifecycle Rules](./examples/s3-bucket-lifecycle-rules)
- [S3 Bucket with Versioning](./examples/s3-bucket-versioning)

### S3 Access Point

- [S3 Access Point (Internet Access)](./examples/s3-access-point-internet)
- [S3 Access Point (VPC Access)](./examples/s3-access-point-vpc)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-data). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022-2023, [Byungjin Park](https://www.posquit0.com).
