provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

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

# module "opensearch_serverless" {
#   source                = "../root-serverless"

#   name                         = var.collection_name
#   use_standby_replicas         = var.use_standby_replicas
#   type                         = var.type
#   create_encryption_policy     = var.create_encryption_policy
#   ingress_rules                = var.ingress_rules
#   egress_rules                 = var.egress_rules
#   vpc_name                     = var.vpc_name
#   vpc_subnet_ids               = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
#   vpc_id                       = var.vpc_id
#   create_data_lifecycle_policy = true
#   create_access_policy         = true
#   create_private_access        = true
#   vpc_create_security_group    = true
#   network_policy_type          = "AllPrivate"
#   data_lifecycle_policy_rules  = local.data_lifecycle_policy_rules
#   vpc_security_group_name      = "arc-vpc-sg"
#   access_policy_rules          = local.access_policy_rules
#   tags = merge(
#     module.terraform-aws-arc-tags.tags
#   )
# }

module "opensearch_without_vpc" {
  source = "../root-serverless"

  name                         = "arc-public"
  create_opensearchserverless  = true
  use_standby_replicas         = var.use_standby_replicas
  type                         = var.type
  create_public_access         = true
  create_access_policy         = true
  create_data_lifecycle_policy = true
  data_lifecycle_policy_rules  = local.data_lifecycle_policy_rules
  access_policy_rules          = local.access_policy_rules
  create_encryption_policy     = var.create_encryption_policy

   tags = merge(
    module.terraform-aws-arc-tags.tags
  )
}
