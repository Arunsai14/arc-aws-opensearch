region               = "us-east-2"
domain_name          = "arc-opensearch-domain"
engine_version       = "OpenSearch 2.15" 
instance_type        = "m4.large.search" 
instance_count       = 2                   
vpc_id               = "vpc-024aff0fdd1a1d6fe"
subnet_ids           = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
allowed_cidr_blocks  = ["172.29.107.0/24"]

anonymous_auth_enabled = true
# EBS settings (optional)
ebs_enabled     = true
volume_type     = "gp2"
volume_size     = 20

master_user_name                    = "admin"
master_user_password                = "Password123!"

# Access policy as a Heredoc block
access_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-2:804295906245:domain/arc-opensearch-domain/*"
    }
  ]
}
POLICY

# access_policy = null