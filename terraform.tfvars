region               = "us-east-2"
domain_name          = "my-opensearch-domain"
engine_version       = "OpenSearch_1.0"

# Cluster configuration
instance_type        = "m4.large.search"
instance_count       = 2
dedicated_master_enabled = false
dedicated_master_type    = "m4.large.search"
zone_awareness_enabled   = true

# VPC Configuration
vpc_id              = "vpc-024aff0fdd1a1d6fe"
subnet_ids          = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
allowed_cidr_blocks = ["172.29.107.0/24"]

# Encryption settings
encrypt_at_rest_enabled         = true
node_to_node_encryption_enabled = true

# Access and Security
enforce_https               = true
tls_security_policy         = "Policy-Min-TLS-1-2-2019-07"
# cloudwatch_log_group_arn    = "arn:aws:logs:us-east-2:1804295906245:log-group:example-log-group"
log_type                    = "INDEX_SLOW_LOGS"

# Fine-grained access control
advanced_security_enabled           = true
anonymous_auth_enabled              = false
internal_user_database_enabled      = true
master_user_name                    = "admin"
master_user_password                = "Password123!"

# Access policy in JSON format
access_policy = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "*"
      },
      "Action" : "es:*",
      "Resource" : "arn:aws:es:us-east-2:804295906245:domain/my-opensearch-domain/*"
    }
  ]
}
POLICY

# Tags for resources
tags = {
  Environment = "dev"
  Project     = "example-project"
}
