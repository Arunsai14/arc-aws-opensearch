variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  default     = "sourcefuse"
  description = "Project name"
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
   default    = "opensearch"
}

variable "engine_version" {
  description = "OpenSearch or Elasticsearch engine version"
  type        = string
  default     = "OpenSearch_1.0"
}

variable "instance_type" {
  description = "Instance type for the OpenSearch domain"
  type        = string
  default     = "m4.large.search"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 2
}

variable "zone_awareness_enabled" {
  description = "Whether zone awareness is enabled"
  type        = bool
  default     = true
}

variable "dedicated_master_enabled" {
  description = "Whether dedicated master is enabled"
  type        = bool
  default     = false
}

variable "dedicated_master_type" {
  description = "Instance type for the dedicated master node"
  type        = string
  default     = "m4.large.search"
}

variable "dedicated_master_count" {
  description = "Number of dedicated master instances"
  type        = number
  default     = 3
}

variable "use_ultrawarm" {
  description = "Whether to enable UltraWarm nodes"
  type        = bool
  default     = false
}

variable "warm_type" {
  description = "UltraWarm node instance type"
  type        = string
  default     = "ultrawarm1.medium.search"
}

variable "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  type        = string
  default     = "arc-example-log-group"
}

variable "retention_in_days" {
  description = "The number of days to retain log events in the log group"
  type        = number
  default     = 7
}

variable "warm_count" {
  description = "Number of UltraWarm instances"
  type        = number
  default     = 2
}

variable "ebs_enabled" {
  description = "Whether EBS is enabled for the domain"
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}

variable "iops" {
  description = "Provisioned IOPS for the volume"
  type        = number
  default     = null
}

variable "throughput" {
  description = "Provisioned throughput for the volume"
  type        = number
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC for OpenSearch domain"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for the OpenSearch domain"
  type        = list(string)
  default     = []
}

variable "encrypt_at_rest_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = ""
}

variable "node_to_node_encryption_enabled" {
  description = "Enable node-to-node encryption"
  type        = bool
  default     = true
}

variable "enforce_https" {
  description = "Force HTTPS on the OpenSearch endpoint"
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "TLS security policy for HTTPS endpoints"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "enable_custom_endpoint" {
  description = "Enable custom domain endpoint"
  type        = bool
  default     = false
}

variable "custom_hostname" {
  description = "Custom domain name for the OpenSearch endpoint"
  type        = string
  default     = ""
}

variable "custom_certificate_arn" {
  description = "ARN of the ACM certificate for the custom endpoint"
  type        = string
  default     = ""
}

variable "enable_snapshot_options" {
  description = "Enable snapshot options for the domain"
  type        = bool
  default     = false
}

variable "snapshot_start_hour" {
  description = "Start hour for the automated snapshot"
  type        = number
  default     = 0
}

variable "log_types" {
  description = "List of log types to publish to CloudWatch (Valid values: INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS, ES_APPLICATION_LOGS, AUDIT_LOGS)"
  type        = list(string)
  default     = ["INDEX_SLOW_LOGS", "SEARCH_SLOW_LOGS"]
}

variable "access_policies" {
  description = "Access policy for the OpenSearch domain"
  type        = string
  default     = null
}

variable "advanced_security_enabled" {
  description = "Enable advanced security options (fine-grained access control)"
  type        = bool
  default     = false
}

variable "anonymous_auth_enabled" {
  description = "Enable anonymous authentication"
  type        = bool
  default     = false
}

variable "internal_user_database_enabled" {
  description = "Enable internal user database for fine-grained access control"
  type        = bool
  default     = true
}

variable "master_user_name" {
  description = "Master user name for OpenSearch"
  type        = string
  default     = "admin"
}

variable "enable_auto_tune" {
  description = "Enable Auto-Tune for the domain"
  type        = bool
  default     = false
}

variable "auto_tune_desired_state" {
  description = "Desired state of Auto-Tune"
  type        = string
  default     = "ENABLED"
}

variable "auto_tune_cron_expression" {
  description = "Cron expression for Auto-Tune maintenance schedule"
  type        = string
  default     = "0 1 * * ?"
}

variable "auto_tune_duration_value" {
  description = "Duration value for Auto-Tune maintenance"
  type        = number
  default     = 1
}

variable "auto_tune_duration_unit" {
  description = "Duration unit for Auto-Tune maintenance"
  type        = string
  default     = "HOURS"
}

variable "auto_tune_start_at" {
  description = "Start time for Auto-Tune maintenance"
  type        = string
  default     = "2024-10-23T01:00:00Z"
}

variable "enable_cognito_options" {
  description = "Enable Cognito authentication for the OpenSearch domain"
  type        = bool
  default     = false
}

variable "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  type        = string
  default     = ""
}

variable "cognito_role_arn" {
  description = "Cognito Role ARN"
  type        = string
  default     = ""
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  type        = string
  default     = ""
}

variable "enable_off_peak_window_options" {
  description = "Enable off-peak window options for the domain"
  type        = bool
  default     = false
}

variable "off_peak_hours" {
  description = "Off-peak window start time (hours)"
  type        = number
  default     = 0
}

variable "off_peak_minutes" {
  description = "Off-peak window start time (minutes)"
  type        = number
  default     = 0
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "cold_storage_enabled" {
  description = "Flag to enable or disable cold storage options"
  type        = bool
  default     = false
}

variable "cold_storage_retention_period" {
  description = "Retention period for cold storage in days"
  type        = number
  default     = 30  # Example default value
}

variable "enable_zone_awareness" {
  description = "Enable zone awareness for the OpenSearch domain."
  type        = bool
  default     = false
}

variable "availability_zone_count" {
  description = "The number of availability zones to use for zone awareness."
  type        = number
  default     = 2
}

variable "enable_domain_endpoint_options" {
  description = "Enable custom domain endpoint options for the OpenSearch domain."
  type        = bool
  default     = false
}

variable "enable_encrypt_at_rest" {
  description = "Enable encryption at rest for the OpenSearch domain."
  type        = bool
  default     = false
}

variable "log_publishing_enabled" {
  description = "Whether to enable the log publishing option."
  type        = bool
  default     = true
}

variable "enable_vpc_options" {
  description = "Enable VPC options for the OpenSearch domain."
  type        = bool
  default     = false  # Set a default value or leave it out if it's required
}

variable "auto_software_update_enabled" {
  description = "Enable automatic software updates for OpenSearch"
  type        = bool
  default     = false
}

# SAML Options
variable "saml_options" {
  description = "Configuration block for SAML options in the OpenSearch domain."
  type = object({
    enabled                 = bool
    idp_entity_id           = optional(string)
    idp_metadata_content    = optional(string)
    roles_key               = optional(string)
    session_timeout_minutes = optional(number)
    subject_key             = optional(string)
  })
  default = {
    enabled                 = false
    idp_entity_id           = null
    idp_metadata_content    = null
    roles_key               = null
    session_timeout_minutes = null
    subject_key             = null
  }
}

variable "use_iam_arn_as_master_user" {
  description = "Set to true to use IAM ARN as the master user, false to create a master user."
  type        = bool
  default     = false
}

variable "master_user_arn" {
  description = "The ARN of the IAM role for fine-grained access control. Required if use_iam_arn_as_master_user is true."
  type        = string
  default     = "" 
}

variable "ingress_rules" {
  description = "A list of ingress rules for the security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default     = []
}

variable "egress_rules" {
  description = "A list of egress rules for the security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default     = []
}

variable "security_group_name" {
  description = "Name for the security group"
  type        = string
  default     = ""
}

variable "rest_action_multi_allow_explicit_index" {
  description = "Setting to control whether to allow explicit index usage in multi-document actions"
  type        = string
  default     = "false"
}

variable "opensearch_cognito_role_name" {
  description = "Name of the OpenSearch Cognito IAM role"
  type        = string
  default     = "opensearch-cognito-role"
}

variable "create_opensearch_domain" {
  description = "Flag to create OpenSearch Serverless resources"
  type        = bool
  default     = true
}


############################################################################################
###########################  create_opensearch_domain ######################################
############################################################################################

variable "collection_name" {
  description = "The name of the OpenSearch collection."
  type        = string
  default     = ""
}

variable "description" {
  description = "A description for the OpenSearch collection."
  type        = string
  default     = "OpenSearch collection domain for logs and search"
}

variable "create_opensearchserverless" {
  description = "Flag to create OpenSearch Serverless resources"
  type        = bool
  default     = false
}

variable "use_standby_replicas" {
  description = "Flag to enable or disable standby replicas."
  type        = bool
  default     = false
}

variable "type" {
  description = "The type of OpenSearch collection."
  type        = string
  default     = "TIMESERIES"
}

variable "create_encryption_policy" {
  description = "Flag to determine if encryption policy should be created."
  type        = bool
  default     = true
}

variable "create_network_policy" {
  description = "Flag to determine if network policy should be created."
  type        = bool
  default     = true
}

variable "vpc_name" {
  description = "The name of the VPC endpoint."
  type        = string
  default   = null
}

variable "vpc_subnet_ids" {
  description = "A list of subnet IDs for the VPC endpoint."
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs for the VPC endpoint."
  type        = list(string)
  default   = []
}

variable "create_access_policy" {
  description = "Flag to determine if access policy should be created."
  type        = bool
  default     = false
}

variable "access_policy_rules" {
  description = "List of rules for the access policy."
  type = list(object({
    resource_type = string
    resource      = list(string)
    permissions   = list(string)
  }))
  default = []
}

variable "create_data_lifecycle_policy" {
  description = "Flag to determine if data lifecycle policy should be created."
  type        = bool
  default     = false
}

variable "data_lifecycle_policy_rules" {
  description = "Data lifecycle policy rules for the indices."
  type = list(object({
    indexes    = list(string)
    retention  = string
  }))
  default = [
    {
      indexes   = ["*"] 
      retention = "Unlimited"
    }
  ]
}
variable "create_security_config" {
  description = "Flag to determine if security configuration should be created."
  type        = bool
  default     = false
}

variable "security_config_name" {
  description = "The name of the security configuration."
  type        = string
  default     = "arc-security-config"
}

variable "vpc_create_security_group" {
  description = "Flag to determine if a security group for VPC endpoint should be created."
  type        = bool
  default     = false
}

variable "vpc_security_group_name" {
  description = "The name of the VPC endpoint security group."
  type        = string
  default     = "opensearch-vpc-sg"
}

variable "network_policy_type" {
  description = "The network policy type, e.g., 'AllPublic' or another specified type."
  type        = string
  default     = "AllPrivate"
}

variable "encryption_policy_kms_key_arn" {
  description = "The ARN of the KMS key to use for OpenSearch encryption. If null, AWS-owned key will be used."
  type        = string
  default     = null
}

variable "create_public_access" {
  description = "Enable or disable public access for the OpenSearch collection"
  type        = bool
  default     = false
}

variable "create_private_access" {
  description = "Enable or disable private access for the OpenSearch collection"
  type        = bool
  default     = false
}