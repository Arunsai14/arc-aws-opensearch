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

  name                         = var.name
  description                  = var.description
  use_standby_replicas         = var.use_standby_replicas
  type                         = var.type
  vpce_security_group_sources      = var.vpce_security_group_sources
  create_encryption_policy     = var.create_encryption_policy
  encryption_policy_name       = var.encryption_policy_name
  encryption_policy_description = var.encryption_policy_description
  vpce_name                    = var.vpce_name
  vpce_subnet_ids              = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
  vpce_vpc_id                  = var.vpce_vpc_id
  vpce_security_group_ids      = var.vpce_security_group_ids
  tags = merge(
    module.terraform-aws-arc-tags.tags
  )
}

# module "opensearch_without_vpc" {
#   source = "./opensearch_without_vpc"

#   name                         = var.name
#   description                  = var.description
#   use_standby_replicas         = var.use_standby_replicas
#   type                         = var.type
#   tags                         = var.tags
#   create_encryption_policy     = var.create_encryption_policy
#   encryption_policy_name       = var.encryption_policy_name
#   encryption_policy_description = var.encryption_policy_description
# }
