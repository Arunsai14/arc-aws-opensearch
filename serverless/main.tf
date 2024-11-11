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
  vpc_id = var.vpce_vpc_id 
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
   network_policy_type = "VPCOnly"
#   vpc_id = var.vpc_id
  vpce_security_group_ids      = var.vpce_security_group_ids
  data_lifecycle_policy_rules = [
  {
    id         = "rule1"
    status     = "Enabled"
    action     = "Delete"
    transition = "archive"
    indexes    = ["index1", "index2"]
    retention  = 30 # Specify retention period in days, or any appropriate value
  },
  {
    id         = "rule2"
    status     = "Disabled"
    action     = "Retain"
    transition = "none"
    indexes    = ["index3"]
    retention  = 60
  }
]
  network_policy_name = "arc_network_policy"
  vpce_security_group_name = "arc_vpce_sg"
  access_policy_rules = [
  {
    action      = "read"
    resource    = "arn:aws:opensearch:${var.region}:${data.aws_caller_identity.current.account_id}:domain/resource1"
    indexes     = ["index1"]
    permissions = ["read"]
    principals  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SomeRole"]
    type        = "AWS_IAM"
  },
  {
    action      = "write"
    resource    = "arn:aws:opensearch:${var.region}:${data.aws_caller_identity.current.account_id}:domain/resource2"
    indexes     = ["index2"]
    permissions = ["write"]
    principals  = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SomeOtherRole"]
    type        = "AWS_IAM"
  }
]

  tags = merge(
    module.terraform-aws-arc-tags.tags
  )
}

# module "opensearch_without_vpc" {
#   source = "../root-serverless"

#   name                         = var.name
#   description                  = var.description
#   use_standby_replicas         = var.use_standby_replicas
#   type                         = var.type
#   tags                         = var.tags
#   create_encryption_policy     = var.create_encryption_policy
#   encryption_policy_name       = var.encryption_policy_name
#   encryption_policy_description = var.encryption_policy_description
# }
