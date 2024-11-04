################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
     version = ">= 5.64"
      source  = "hashicorp/aws"
    }
  }

  #backend "s3" {}
}

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
  region            = var.region
  domain_name       = var.domain_name
  engine_version    = var.engine_version
  instance_type     = var.instance_type
  instance_count    = var.instance_count
  enable_vpc_options = false

  # vpc_id            = var.vpc_id
  # subnet_ids        = var.subnet_ids
  # ingress_rules = var.ingress_rules
  # egress_rules  = var.egress_rules


  enable_encrypt_at_rest = false
  auto_software_update_enabled = false
  enable_domain_endpoint_options = false

  # enable_auto_tune = false
  # auto_tune_desired_state     = "ENABLED"
  # auto_tune_cron_expression   = "cron(0 1 * * ? *)"
  # auto_tune_duration_value    = 1
  # auto_tune_duration_unit     = "HOURS"
  # auto_tune_start_at          = "2024-11-04T01:00:00Z"


  dedicated_master_enabled = true
  dedicated_master_type  = "m5.large.search"
  dedicated_master_count = 3
  master_user_name                    = "admin"
  # master_user_password                = "Password123!"

  advanced_security_enabled = true
  access_policies     = var.access_policy             
  allowed_cidr_blocks = var.allowed_cidr_blocks 

  enable_zone_awareness = true
  availability_zone_count = 2
   ebs_enabled  = var.ebs_enabled
    volume_type  = var.volume_type
    volume_size  = var.volume_size
    iops         = var.iops
    throughput   = var.throughput

tags = merge(
    module.terraform-aws-arc-tags.tags
  )

}
