###################################################
# Prepared Statements
###################################################

resource "aws_athena_prepared_statement" "this" {
  for_each = {
    for statement in var.prepared_statements :
    "${statement.database}:${statement.name}" => statement
  }

  region = var.region

  workgroup   = aws_athena_workgroup.this.id
  name        = each.value.name
  description = each.value.description

  query_statement = each.value.query
}


###################################################
# Named Queries (Legacy)
###################################################

resource "aws_athena_named_query" "this" {
  for_each = {
    for query in var.named_queries :
    "${query.database}:${query.name}" => query
  }

  region = var.region

  workgroup   = aws_athena_workgroup.this.id
  name        = each.value.name
  description = each.value.description

  database = each.value.database
  query    = each.value.query
}
