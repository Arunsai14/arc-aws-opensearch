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

module "opensearch_serverless" {
  source                = "../root-serverless"

  name                         = var.name
  description                  = var.description
  use_standby_replicas         = var.use_standby_replicas
  type                         = var.type
  create_encryption_policy     = var.create_encryption_policy
  encryption_policy_name       = var.encryption_policy_name
  encryption_policy_description = var.encryption_policy_description
  ingress_rules      = var.ingress_rules
  egress_rules       = var.egress_rules
  vpc_name                    = var.vpc_name
  vpc_subnet_ids              = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
  vpc_id                  = var.vpc_id
  create_data_lifecycle_policy = true
  create_access_policy         = true
  create_private_access        = true
  vpc_create_security_group    = true
   network_policy_type = "AllPrivate"
#   vpc_id = var.vpc_id
  vpc_security_group_ids      = var.vpc_security_group_ids
  data_lifecycle_policy_rules = [
  {
    id         = "rule1"
    status     = "Enabled"
    action     = "Delete"
    transition = "archive"
    indexes    = ["index1", "index2"]
    retention  = "30d" # Specify retention period in days, or any appropriate value
  },
  {
    id         = "rule2"
    status     = "Disabled"
    action     = "Retain"
    transition = "none"
    indexes    = ["index3"]
    retention  = "24h"
  }
]
  network_policy_name = "arc-network-policy"
  vpc_security_group_name = "arc-vpc-sg"
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
#   create_public_access         = true
#   create_encryption_policy     = var.create_encryption_policy
#   encryption_policy_name       = var.encryption_policy_name
#   encryption_policy_description = var.encryption_policy_description
#    tags = merge(
#     module.terraform-aws-arc-tags.tags
#   )
# }
