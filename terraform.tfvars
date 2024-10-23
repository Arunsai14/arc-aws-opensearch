region               = "us-east-2"
domain_name          = "my-opensearch-domain"
engine_version       = "OpenSearch_1.0"

# Cluster configuration
instance_type        = "m4.large.search"
instance_count       = 2
dedicated_master_enabled = false
dedicated_master_type    = "m4.large.search"
zone_awareness_enabled   = true

# UltraWarm settings (optional)
use_ultrawarm    = false
warm_type        = "ultrawarm1.medium.search"
warm_count       = 2

# VPC Configuration
vpc_id              = "vpc-024aff0fdd1a1d6fe"
subnet_ids          = ["subnet-0559fb2ec2711b6ae", "subnet-0ecaddef65763a35f"]
allowed_cidr_blocks = ["172.29.107.0/24"]

# EBS settings (optional)
ebs_enabled     = true
volume_type     = "gp2"
volume_size     = 20
iops            = null
throughput      = null

# Encryption settings
encrypt_at_rest_enabled         = true
kms_key_id                      = ""
node_to_node_encryption_enabled = true

# Access and Security
enforce_https               = true
tls_security_policy         = "Policy-Min-TLS-1-2-2019-07"
log_type                    = "INDEX_SLOW_LOGS"

# Fine-grained access control
advanced_security_enabled           = true
anonymous_auth_enabled              = false
internal_user_database_enabled      = true
master_user_name                    = "admin"
master_user_password                = "Password123!"

# Auto-Tune settings (optional)
enable_auto_tune            = true
auto_tune_desired_state     = "ENABLED"
auto_tune_cron_expression   = "0 1 * * ?"
auto_tune_duration_value    = 1
auto_tune_duration_unit     = "HOURS"
auto_tune_start_at          = "2024-10-24T01:00:00Z"

# Cognito options (optional)
enable_cognito_options      = false
cognito_identity_pool_id    = ""
cognito_role_arn            = ""
cognito_user_pool_id        = ""

# Off-Peak Window settings (optional)
enable_off_peak_window_options = false
off_peak_hours                 = 0
off_peak_minutes               = 0

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
