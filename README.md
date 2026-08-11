# terraform-aws-data

![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/tedilabs/terraform-aws-data?color=blue&sort=semver&style=flat-square)
![GitHub](https://img.shields.io/github/license/tedilabs/terraform-aws-data?color=blue&style=flat-square)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white&style=flat-square)](https://github.com/pre-commit/pre-commit)

Terraform module which creates data related resources on AWS.

- [athena-data-catalog](./modules/athena-data-catalog)
- [athena-workgroup](./modules/athena-workgroup)
- [glue-connection](./modules/glue-connection)
- [glue-crawler](./modules/glue-crawler)
- [glue-data-catalog](./modules/glue-data-catalog)
- [glue-database](./modules/glue-database)
- [glue-table](./modules/glue-table)

> [!NOTE]
> S3 related modules have moved to [tedilabs/terraform-aws-s3](https://github.com/tedilabs/terraform-aws-s3). Each module in the new package drops the `s3-` prefix from its name. (e.g. `s3-bucket` → `bucket`)


## Target AWS Services

Terraform Modules from [this package](https://github.com/tedilabs/terraform-aws-data) were written to manage the following AWS Services with Terraform.

- **AWS Athena**
  - Data Catalog
  - Workgroup
    - Named Query
    - Prepared Statement
- **AWS Glue**
  - Data Catalog
    - Connection
    - Crawler
    - Data Catalog
    - Database
    - Table


## Examples

### Athena

- [Athena Workgroup](./examples/athena-workgroup)

### Glue

- [Glue Data Catalog (Simple)](./examples/glue-data-catalog-simple)
- [Glue Data Catalog (Full)](./examples/glue-data-catalog-full)


## Self Promotion

Like this project? Follow the repository on [GitHub](https://github.com/tedilabs/terraform-aws-data). And if you're feeling especially charitable, follow **[posquit0](https://github.com/posquit0)** on GitHub.


## License

Provided under the terms of the [Apache License](LICENSE).

Copyright © 2022-2026, [Byungjin Park](https://www.posquit0.com).