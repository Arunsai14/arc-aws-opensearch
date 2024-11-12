################################################################################
## defaults
################################################################################
# terraform {
#   required_version = "~> 1.3"

#   required_providers {
#     aws = {
#      version = ">= 5.64"
#       source  = "hashicorp/aws"
#     }
#   }

#   #backend "s3" {}
# }

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


module "opensearch" {
  source            = "../" 
  create_opensearch = true
  create_opensearchserverless  = false
  name       = var.domain_name
  engine_version     = var.engine_version
  instance_type      = var.instance_type
  instance_count     = var.instance_count
  enable_vpc_options = true

  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  ingress_rules      = var.ingress_rules
  egress_rules       = var.egress_rules
  enable_cognito_options = false
  cognito_identity_pool_id = "us-east-2:e4d2566f-6f93-4a2d-885a-5963d8730f58"
  cognito_user_pool_id = "us-east-2_PWWrC23P1"

  # access_policies                = local.access_policy
  # enable_zone_awareness          = false
  # tags                           = module.tags.tags

  # enable_encrypt_at_rest = false

  # enable_domain_endpoint_options = false

  # enable_off_peak_window_options = true
  # auto_software_update_enabled   = true
  #   advanced_security_enabled = false
  # access_policies     = var.access_policy  

  # enable_auto_tune = false
  # auto_tune_desired_state     = "ENABLED"
  # auto_tune_cron_expression   = "cron(0 1 * * ? *)"
  # auto_tune_duration_value    = 1
  # auto_tune_duration_unit     = "HOURS"
  # auto_tune_start_at          = "2024-11-04T01:00:00Z"


  # dedicated_master_enabled = false
  # dedicated_master_type  = "m5.large.search"
  # dedicated_master_count = 3
  # master_user_name                    = "admin"
  # master_user_password                = "Password123!"

           
  # allowed_cidr_blocks = var.allowed_cidr_blocks 

  # enable_zone_awareness = false
  # availability_zone_count = 2
  #  ebs_enabled  = var.ebs_enabled
  #   volume_type  = var.volume_type
  #   volume_size  = var.volume_size
  #   iops         = var.iops
  #   throughput   = var.throughput


tags = merge(
    module.terraform-aws-arc-tags.tags
  )

}

module "opensearch_without_vpc" {
  source = "../"

  collection_name              = var.collection_name
  create_opensearch_serverless  = false
   create_opensearch = false
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

module "opensearch_serverless" {
  source                = "../root-serverless"

  name                         = var.collection_name
  create_opensearch_serverless = true
  create_opensearch            = false
  use_standby_replicas         = var.use_standby_replicas
  type                         = var.type
  create_encryption_policy     = var.create_encryption_policy
  ingress_rules                = var.ingress_rules
  egress_rules                 = var.egress_rules
  vpc_name                     = var.vpc_name
  vpc_subnet_ids               = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
  vpc_id                       = var.vpc_id
  create_data_lifecycle_policy = true
  create_access_policy         = true
  create_private_access        = true
  vpc_create_security_group    = true
  network_policy_type          = "AllPrivate"
  data_lifecycle_policy_rules  = local.data_lifecycle_policy_rules
  vpc_security_group_name      = "arc-vpc-sg"
  access_policy_rules          = local.access_policy_rules
  tags = merge(
    module.terraform-aws-arc-tags.tags
  )
}