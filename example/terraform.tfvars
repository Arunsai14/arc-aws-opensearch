region               = "us-east-2"
domain_name          = "arc-opensearch-domain"
engine_version       = "OpenSearch_2.15" 
instance_type        = "m5.large.search" 
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

# access_policy = null