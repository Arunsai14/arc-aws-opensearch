region               = "us-east-2"
vpc_id               = "vpc-024aff0fdd1a1d6fe"
name                         = "arc-opensearch-domain"
use_standby_replicas         = true
type                         = "TIMESERIES"
create_encryption_policy     = true
encryption_policy_name       = "opensearch-encryption-policy"
encryption_policy_description = "Encryption policy for OpenSearch domain"
vpc_name                    = "vpc-test"
vpc_security_group_ids      = ["sg-0fa6b2a413e945f0a"]

access_policy_rules = [
  {
    resource_type = "collection"
    resource      = ["collection/my-collection"]
    permissions   = ["aoss:CreateCollectionItems", "aoss:DeleteCollectionItems", "aoss:UpdateCollectionItems", "aoss:DescribeCollectionItems"]
  },
]
ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # "-1" allows all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
]