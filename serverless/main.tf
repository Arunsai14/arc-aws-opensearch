provider "aws" {
  region = var.region
}

module "terraform-aws-arc-tags" {
  source      = "sourcefuse/arc-tags/aws"
  version     = "1.2.5"
  environment = var.environment
  project     = var.project_name

  extra_tags = {
    MonoRepo     = "True"
    MonoRepoPath = "opensearch"
  }
}

data "aws_route_tables" "selected" {
  vpc_id = var.vpc_id 
}

module "opensearch_serverless" {
  source                = "../root-serverless"
  vpc_id                = var.vpc_id
    ingress_rules      = var.ingress_rules
  egress_rules       = var.egress_rules
  network_type          = "vpc"
  security_group_name   = "serverless-open"
  collection_resource   = "collection/example-collection"
  encryption_policy_name = "custom-encryption-policy"
  collection_name       = "custom-collection"
  collection_description = "Custom description for the OpenSearch collection"
  standby_replicas      = "ENABLED"
  collection_type       = "TIMESERIES"
  route_table_ids   = data.aws_route_tables.selected.ids 
  public_access         = true
  tags = merge(
    module.terraform-aws-arc-tags.tags
  )
}
