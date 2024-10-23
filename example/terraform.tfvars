region               = "us-east-2"
domain_name          = "arc-opensearch-domain"
engine_version    = "OpenSearch_1.0" 
instance_type     = "m4.large.search" 
instance_count    = 2                   
vpc_id              = "vpc-024aff0fdd1a1d6fe"
subnet_ids          = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
allowed_cidr_blocks = ["172.29.107.0/24"]

enable_zone_awareness = true

# EBS settings (optional)
ebs_enabled     = true
volume_type     = "gp2"
volume_size     = 20
iops            = null
throughput      = null