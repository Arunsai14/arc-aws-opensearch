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

resource "aws_cloudwatch_log_group" "this" {
  name              = "arc-example-log-group"
  retention_in_days = 7
}

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

resource "aws_opensearch_domain" "this" {
  domain_name    = var.domain_name
  engine_version = var.engine_version

  # Cluster configuration
  cluster_config {
    instance_type              = var.instance_type
    instance_count             = var.instance_count
    zone_awareness_enabled     = var.zone_awareness_enabled
    dedicated_master_enabled   = var.dedicated_master_enabled
    dedicated_master_type      = var.dedicated_master_enabled ? var.dedicated_master_type : null
    dedicated_master_count     = var.dedicated_master_enabled ? var.dedicated_master_count : 0
    warm_enabled               = var.use_ultrawarm ? true : false
    warm_type                  = var.use_ultrawarm ? var.warm_type : null
    warm_count                 = var.use_ultrawarm ? var.warm_count : null
  }

  # Optional ebs options
  ebs_options {
    ebs_enabled  = var.ebs_enabled
    volume_type  = var.volume_type
    volume_size  = var.volume_size
    iops         = var.iops
    throughput   = var.throughput
  }

  # VPC Options
  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.opensearch_sg.id]
  }

  # Advanced options
  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  # Snapshot options (conditionally added)
  dynamic "snapshot_options" {
    for_each = var.enable_snapshot_options ? [1] : []
    content {
      automated_snapshot_start_hour = var.snapshot_start_hour
    }
  }

  # Access policies
  access_policies = var.access_policy

  # Encryption options
  encrypt_at_rest {
    enabled  = var.encrypt_at_rest_enabled
    kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null
  }

  # Node-to-node encryption
  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  # Domain endpoint options
  domain_endpoint_options {
    enforce_https                = var.enforce_https
    tls_security_policy          = var.tls_security_policy
    custom_endpoint              = var.enable_custom_endpoint ? var.custom_hostname : null
    custom_endpoint_certificate_arn = var.enable_custom_endpoint ? var.custom_certificate_arn : null
  }

  # Log publishing options
  log_publishing_options {
    log_type                 = var.log_type
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.this.arn
  }

  # Advanced security options
  advanced_security_options {
    enabled                        = var.advanced_security_enabled
    anonymous_auth_enabled         = var.anonymous_auth_enabled
    internal_user_database_enabled = var.internal_user_database_enabled

    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  # Auto-Tune options (conditionally added)
  dynamic "auto_tune_options" {
    for_each = var.enable_auto_tune ? [1] : []
    content {
      desired_state = var.auto_tune_desired_state

      maintenance_schedule {
        cron_expression_for_recurrence = var.auto_tune_cron_expression
        duration {
          value = var.auto_tune_duration_value
          unit  = var.auto_tune_duration_unit
        }
        auto_tune_start_at = var.auto_tune_start_at
      }
    }
  }

  # Cognito options (conditionally added)
  dynamic "cognito_options" {
    for_each = var.enable_cognito_options ? [1] : []
    content {
      enabled           = true
      identity_pool_id  = var.cognito_identity_pool_id
      role_arn          = var.cognito_role_arn
      user_pool_id      = var.cognito_user_pool_id
    }
  }

  # Off-peak window options (conditionally added)
  dynamic "off_peak_window_options" {
    for_each = var.enable_off_peak_window_options ? [1] : []
    content {
      enabled   = true
      off_peak_window {
        window_start_time {
          hours   = var.off_peak_hours
          minutes = var.off_peak_minutes
        }
      }
    }
  }

  # Tags
  tags = var.tags
}
