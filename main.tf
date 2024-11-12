provider "aws" {
  region = var.region
}

######## OpenSearch Security Group Options #######
resource "aws_security_group" "opensearch_sg" {
  count       = var.create_opensearch_domain && var.enable_vpc_options ? 1 : 0
  name        = var.security_group_name
  description = "Security group for the OpenSearch Domain"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = var.tags
}

resource "aws_kms_key" "op_log_group_key" {
  count = var.create_opensearch_domain ? 1 : 0
  description             = "KMS key for CloudWatch log group encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "EnableRootPermissions",
        Effect    = "Allow",
        Principal = { AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action    = [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudWatchLogs",
        Effect    = "Allow",
        Principal = { Service = "logs.${var.region}.amazonaws.com" },
        Action    = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource  = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "op_log_group_key_alias" {
  count = var.create_opensearch_domain ? 1 : 0
  name          = "alias/cloudwatch-os-log-group-key"
  target_key_id = aws_kms_key.op_log_group_key.id
}

######## CloudWatch Log Group Options #######
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_opensearch_domain ? 1 : 0
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = aws_kms_key.op_log_group_key.arn

  depends_on = [aws_kms_key.op_log_group_key]
}

######## CloudWatch Log Resource Policy Options #######
resource "aws_cloudwatch_log_resource_policy" "this" {
  count = var.create_opensearch_domain ? 1 : 0
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

######### Generate a random password #########
resource "random_password" "master_user_password" {
  count     = var.create_opensearch_domain && var.advanced_security_enabled && !var.use_iam_arn_as_master_user ? 1 : 0
  length           = 32
  special          = true
  upper            = true
  lower            = true
  numeric           = true
  override_special = "!@#$%^&*()-_=+[]{}"
}

######### Store the generated password in ssm #########
resource "aws_ssm_parameter" "master_user_password" {
  count     = var.create_opensearch_domain && var.advanced_security_enabled && !var.use_iam_arn_as_master_user ? 1 : 0
  name      = "/opensearch/${var.domain_name}/master_user_password"
  type      = "SecureString"
  value     = random_password.master_user_password[0].result
}

######### IAM role for OpenSearch Service Cognito Access ########
resource "aws_iam_role" "opensearch_cognito_role" {
  count = var.create_opensearch_domain && var.enable_cognito_options ? 1 : 0
  name = var.opensearch_cognito_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "es.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the AmazonOpenSearchServiceCognitoAccess managed policy to the role
resource "aws_iam_role_policy_attachment" "opensearch_cognito_policy_attachment" {
  count     = var.create_opensearch_domain && var.enable_cognito_options ? 1 : 0
  role       = aws_iam_role.opensearch_cognito_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceCognitoAccess"
}

##############################################
######## OpenSearch Domain Options ###########
##############################################
resource "aws_opensearch_domain" "this" {
  count = var.create_opensearch_domain ? 1 : 0
  domain_name    = var.domain_name
  engine_version = var.engine_version

  ######## Cluster configuration #######
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

    dynamic "zone_awareness_config" {
      for_each = var.enable_zone_awareness ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  ######## EBS options #######
  ebs_options {
    ebs_enabled  = var.ebs_enabled
    volume_type  = var.volume_type
    volume_size  = var.volume_size
    iops         = var.iops
    throughput   = var.throughput
  }

  ######## VPC Options #######
  dynamic "vpc_options" {
    for_each = var.create_opensearch_domain && var.enable_vpc_options ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = [aws_security_group.opensearch_sg[0].id]
    }
  }

  ######## Snapshot options #######
  dynamic "snapshot_options" {
    for_each = var.create_opensearch_domain && var.enable_snapshot_options ? [1] : []
    content {
      automated_snapshot_start_hour = var.snapshot_start_hour
    }
  }

  ######## Encryption options #######
  dynamic "encrypt_at_rest" {
    for_each = var.create_opensearch_domain && var.enable_encrypt_at_rest ? [1] : []
    content {
      enabled    = var.encrypt_at_rest_enabled
      kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null
    }
  }

  ######## Node-to-node encryption options #######
  node_to_node_encryption {
    enabled = var.create_opensearch_domain && var.node_to_node_encryption_enabled
  }

  ######## Domain endpoint #######
  dynamic "domain_endpoint_options" {
    for_each = var.create_opensearch_domain && var.enable_domain_endpoint_options ? [1] : []
    content {
      enforce_https                = var.enforce_https
      tls_security_policy          = var.tls_security_policy
      custom_endpoint              = var.enable_custom_endpoint ? var.custom_hostname : null
      custom_endpoint_certificate_arn = var.enable_custom_endpoint ? var.custom_certificate_arn : null
    }
  }

  ###### access_policies #######
  access_policies = var.create_opensearch_domain ? var.access_policies : []

  ######## Log publishing options #######
    dynamic "log_publishing_options" {
    for_each = var.create_opensearch_domain && var.log_types ? [1] : []
    content {
      log_type                 = log_publishing_options.value
      enabled                  = var.log_publishing_enabled
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.this.arn
    }
  }

  ######## Advanced Security Options #######
  dynamic "advanced_security_options" {
    for_each = var.create_opensearch_domain && var.advanced_security_enabled ? [1] : []
    content {
      enabled                        = true
      anonymous_auth_enabled         = var.anonymous_auth_enabled
      internal_user_database_enabled = var.internal_user_database_enabled

      ######### master user options or IAM ARN ########
      dynamic "master_user_options" {
        for_each = var.create_opensearch_domain && var.use_iam_arn_as_master_user ? [] : [1]
        content {
          master_user_name     = var.master_user_name
          master_user_password = aws_ssm_parameter.master_user_password[0].value
          master_user_arn = var.use_iam_arn_as_master_user ? var.master_user_arn : null
        }
      }
      
    }
  }
  ######## Auto-Tune options #######
  dynamic "auto_tune_options" {
    for_each = var.create_opensearch_domain && var.enable_auto_tune ? [1] : []
    content {
      desired_state = var.auto_tune_desired_state

      dynamic "maintenance_schedule" {
        for_each = var.create_opensearch_domain && var.enable_auto_tune ? [1] : [] 
        content {
          cron_expression_for_recurrence = var.auto_tune_cron_expression
          duration {
            value = var.auto_tune_duration_value
            unit  = var.auto_tune_duration_unit
          }
          start_at = var.auto_tune_start_at
        }
      }
    }
  }

  ######## Cognito options #######
  dynamic "cognito_options" {
    for_each = var.create_opensearch_domain && var.enable_cognito_options ? [1] : []
    content {
      enabled           = true
      identity_pool_id  = var.cognito_identity_pool_id
      role_arn          = aws_iam_role.opensearch_cognito_role[0].arn
      user_pool_id      = var.cognito_user_pool_id
    }
  }

  ######## Off-peak window options #######
  dynamic "off_peak_window_options" {
    for_each = var.create_opensearch_domain && var.enable_off_peak_window_options ? [1] : []
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

  ######## Software update options #######
  software_update_options {
    auto_software_update_enabled = var.auto_software_update_enabled
  }

  ######## Tags #######
  tags = var.tags
}

######## SAML Options #######
resource "aws_opensearch_domain_saml_options" "this" {
  count       = var.create_opensearch_domain && var.saml_options.enabled ? 1 : 0
  domain_name = aws_opensearch_domain.this.domain_name

  saml_options {
    idp {
      entity_id        = var.saml_options.idp_entity_id
      metadata_content = var.saml_options.idp_metadata_content
    }
    roles_key               = var.saml_options.roles_key
    session_timeout_minutes = var.saml_options.session_timeout_minutes
    subject_key             = var.saml_options.subject_key
  }
}

##################################################
######## OpenSearch Serverless Domain  ###########
##################################################



resource "aws_opensearchserverless_collection" "this" {
  count = var.create_opensearchserverless == true ? 1 : 0
  name             = var.collection_name
  description      = var.description
  standby_replicas = var.use_standby_replicas ? "ENABLED" : "DISABLED"
  type             = var.type
  tags             = var.tags
  depends_on       = [aws_opensearchserverless_security_policy.encryption]
}

######### encryption policy #########
resource "aws_opensearchserverless_security_policy" "encryption" {
  count       = var.create_opensearchserverless == true && var.create_encryption_policy ? 1 : 0
  name        = "${var.collection_name}-encryption"
  type        = "encryption"
  description = "Encryption policy for OpenSearch collection"
  policy = jsonencode(merge(
    {
      "Rules" = [
        {
          "Resource"     = ["collection/${var.collection_name}"]
          "ResourceType" = "collection"
        }
      ],
    },
    {
      "AWSOwnedKey" = true  
    }
  ))
}


########## Public access policy #########
resource "aws_opensearchserverless_security_policy" "public_network" {
  count       = var.create_opensearchserverless == true && var.create_public_access ? 1 : 0
  name        = "${var.collection_name}-public-policy" 
  type        = "network"
  description = "Public access policy for ${var.collection_name}"
  policy      = jsonencode([{
    "Rules" = [
      {
        "ResourceType" = "collection",
        "Resource"     = ["collection/${var.collection_name}"]
      },
      {
        "ResourceType" = "dashboard",
        "Resource"     = ["collection/${var.collection_name}"]
      },
    ],
    "AllowFromPublic" = true,
  }])
}

########## Private access policy #########
resource "aws_opensearchserverless_security_policy" "private_network" {
  count       = var.create_opensearchserverless == true && var.create_private_access && !var.create_public_access ? 1 : 0 
  name        = "${var.collection_name}-private-policy"
  type        = "network"
  description = "Private VPC access policy for ${var.collection_name}"
  policy      = jsonencode([{
    "Rules" = [
      {
        "ResourceType" = "collection",
        "Resource"     = ["collection/${var.collection_name}"]
      },
      {
        "ResourceType" = "dashboard",
        "Resource"     = ["collection/${var.collection_name}"]
      }
    ],
    "AllowFromPublic" = false,
    "SourceVPCEs" = [aws_opensearchserverless_vpc_endpoint.this[0].id],
  }])
}

########## VPC endpoint #########
resource "aws_opensearchserverless_vpc_endpoint" "this" {
  count              = var.create_opensearchserverless == true && var.create_private_access && !var.create_public_access ? 1 : 0 
  name               = var.vpc_name
  subnet_ids         = var.vpc_subnet_ids
  vpc_id             = var.vpc_id
  security_group_ids = [aws_security_group.this[0].id]
}

########## access role #########
resource "aws_iam_role" "opensearch_access_role" {
  count = var.create_opensearchserverless == true && var.create_access_policy ? 1 : 0 
  name = "${var.collection_name}-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "es.amazonaws.com"  
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

########## role cuetom policy #########
resource "aws_iam_policy" "opensearch_custom_policy" {
  count = var.create_opensearchserverless == true && var.create_access_policy ? 1 : 0 
  name        = "${var.collection_name}-os-custompolicy"
  description = "Custom policy for OpenSearch Serverless access"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "aoss:ReadDocument",
          "aoss:WriteDocument",
          "aoss:DescribeIndex",
          "aoss:*"
        ],
        "Resource": "*"
      }
    ]
  })
}

########## role attachment policy #########
resource "aws_iam_role_policy_attachment" "opensearch_access_policy_attachment" {
  count      = var.create_opensearchserverless == true && var.create_access_policy ? 1 : 0 
  role       = aws_iam_role.opensearch_access_role[0].name
  policy_arn = aws_iam_policy.opensearch_custom_policy[0].arn 
} 

########## access policy #########
resource "aws_opensearchserverless_access_policy" "this" {
  count       = var.create_opensearchserverless == true && var.create_access_policy ? 1 : 0
  name        = "${var.collection_name}-access-policy"
  type        = "data"
  description = "Network policy description"

  # Define the policy with required permissions
  policy = jsonencode([
    for rule in var.access_policy_rules : {
      "Rules" = [
        {
          "ResourceType" = rule.resource_type
          "Resource"     = rule.resource
          "Permission"   = rule.permissions
        }
      ],
    "Principal" = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.opensearch_access_role[0].name}"
    ]
  }])
}

########## lifecycle policy #########
resource "aws_opensearchserverless_lifecycle_policy" "this" {
  count       = var.create_opensearchserverless == true && var.create_data_lifecycle_policy ? 1 : 0
  name        = "${var.collection_name}-data-policy"
  type        = "retention"
  description = "Data lifecycle policy description"
  policy      = jsonencode({
    Rules = [
      for rule in var.data_lifecycle_policy_rules : {
        ResourceType      = "index",
        Resource          = [for index in rule.indexes : "index/${var.collection_name}/${index}"],
        MinIndexRetention = rule.retention != "Unlimited" ? rule.retention : null
      }
    ]
  })
}

########### Security Group for serverless ######### 
resource "aws_security_group" "this" {
  count       = var.create_opensearchserverless == true && var.create_network_policy && var.network_policy_type != "AllPublic" && var.vpc_create_security_group ? 1 : 0
  name        = var.vpc_security_group_name
  description = "Security group for the OpenSearch collection"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = var.tags
}