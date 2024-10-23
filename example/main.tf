################################################################################
## defaults
################################################################################
terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      version = "~> 4.0"
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
  source            = "./modules/opensearch"  # Path to your child module
  region            = var.region
  domain_name       = var.domain_name
  engine_version    = var.engine_version
  instance_type     = var.instance_type
  instance_count    = var.instance_count
  vpc_id            = var.vpc_id                
  allowed_cidr_blocks = var.allowed_cidr_blocks 

  enable_zone_awareness = true
  availability_zone_count = 2
   ebs_enabled  = var.ebs_enabled
    volume_type  = var.volume_type
    volume_size  = var.volume_size
    iops         = var.iops
    throughput   = var.throughput

}
