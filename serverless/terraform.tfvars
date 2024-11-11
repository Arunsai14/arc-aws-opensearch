region               = "us-east-2"
vpce_vpc_id               = "vpc-024aff0fdd1a1d6fe"
vpc_id               = "vpc-024aff0fdd1a1d6fe"
name                         = "opensearch-domain"
description                  = "OpenSearch domain for logs and search"
use_standby_replicas         = true
type                         = "TIMESERIES"
create_encryption_policy     = true
encryption_policy_name       = "opensearch-encryption-policy"
encryption_policy_description = "Encryption policy for OpenSearch domain"
vpce_name                    = "vpc-test"
vpce_security_group_ids      = ["sg-0c71f9a200077617b", "sg-0fa6b2a413e945f0a"]

vpce_security_group_sources = [
  {
    type    = "IPv4"
    sources = ["192.168.1.0/24"]
  },
  {
    type    = "IPv6"
    sources = ["2001:db8::/32"]
  }
]