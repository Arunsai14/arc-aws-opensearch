provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "opensearch_sg" {
  description = "Security group for OpenSearch Domain"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Create CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "arc-example-log-group" 
  retention_in_days = 7                    
}

# Create CloudWatch Log Resource Policy
resource "aws_cloudwatch_log_resource_policy" "this" {
  policy_name = "opensearch-log-group-policy"

  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "opensearchservice.amazonaws.com"
        },
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.this.name}:*"
      }
    ]
  })
}

# Create OpenSearch Domain
resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type               = var.instance_type
    zone_awareness_enabled       = var.zone_awareness_enabled
    dedicated_master_enabled      = var.dedicated_master_enabled
    dedicated_master_type        = var.dedicated_master_enabled ? var.dedicated_master_type : null
    dedicated_master_count       = var.dedicated_master_enabled ? var.dedicated_master_count : 0
    instance_count               = var.instance_count

    # Only include warm configuration if UltraWarm is enabled
    warm_enabled                 = var.use_ultrawarm ? true : false
    warm_count                   = var.use_ultrawarm ? var.warm_count : null  # Use null instead of 0
    warm_type                    = var.use_ultrawarm ? var.warm_type : null
  }

  ebs_options {
    ebs_enabled  = true
    volume_type  = "gp2"
    volume_size  = 20
  }

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  # Access policies for the domain
  access_policies = var.access_policy

  # Encryption settings
  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }

  # Node-to-node encryption
  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  # Domain endpoint options
  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
    custom_endpoint     = var.enable_custom_endpoint ? var.custom_hostname : null
    custom_endpoint_certificate_arn = var.enable_custom_endpoint ? var.custom_certificate_arn : null
  }

  # Enable logging
  log_publishing_options {
    log_type                 = var.log_type
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.this.arn
  }

  # Advanced security options (fine-grained access control)
  advanced_security_options {
    enabled                        = var.advanced_security_enabled
    anonymous_auth_enabled         = var.anonymous_auth_enabled
    internal_user_database_enabled = var.internal_user_database_enabled

    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  # Tags for the domain
  tags = var.tags
}

