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

module "opensearch_serverless" {
  source                = "../root-serverless"
  vpc_id                = var.vpc_id
  collection_resource   = "collection/example-collection"
  encryption_policy_name = "custom-encryption-policy"
  collection_name       = "custom-collection"
  collection_description = "Custom description for the OpenSearch collection"
  standby_replicas      = "ENABLED"
  collection_type       = "TIMESERIES"
  public_access         = true
  tags = merge(
    module.terraform-aws-arc-tags.tags
  )
}
