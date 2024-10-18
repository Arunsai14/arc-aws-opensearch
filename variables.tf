variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Name of the OpenSearch domain"
  type        = string
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

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 2
}

variable "vpc_id" {
  description = "ID of the VPC for OpenSearch domain"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the OpenSearch domain"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for ingress"
  type        = list(string)
}

variable "encrypt_at_rest_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "node_to_node_encryption_enabled" {
  description = "Enable node-to-node encryption"
  type        = bool
  default     = true
}

variable "enforce_https" {
  description = "Enforce HTTPS for the domain endpoint"
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "TLS security policy"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

# variable "cloudwatch_log_group_arn" {
#   description = "ARN of the CloudWatch log group for publishing logs"
#   type        = string
# }

variable "log_type" {
  description = "Type of log to publish (e.g., INDEX_SLOW_LOGS, SEARCH_SLOW_LOGS)"
  type        = string
}

variable "advanced_security_enabled" {
  description = "Enable fine-grained access control"
  type        = bool
  default     = false
}

variable "anonymous_auth_enabled" {
  description = "Enable anonymous authentication"
  type        = bool
  default     = false
}

variable "internal_user_database_enabled" {
  description = "Enable internal user database"
  type        = bool
  default     = true
}

variable "master_user_name" {
  description = "Master user name for the OpenSearch domain"
  type        = string
}

variable "master_user_password" {
  description = "Master user password for the OpenSearch domain"
  type        = string
}

variable "access_policy" {
  description = "IAM access policy for the OpenSearch domain"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the OpenSearch domain"
  type        = map(string)
}

variable "use_ultrawarm" {
  description = "Enable UltraWarm data nodes"
  type        = bool
  default     = false  # Change this to true to enable UltraWarm data nodes
}

variable "dedicated_master_enabled" {
  description = "Enable dedicated master nodes"
  type        = bool
  default     = false  # Change this to true if you want to enable dedicated master nodes
}

variable "dedicated_master_type" {
  description = "Instance type for dedicated master nodes"
  type        = string
  default     = "r5.large.search"  # Example instance type
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes"
  type        = number
  default     = 3  # Adjust based on your needs
}

variable "warm_count" {
  description = "Number of UltraWarm data nodes"
  type        = number
  default     = 2  # Adjust based on your needs
}

variable "warm_type" {
  description = "Instance type for UltraWarm data nodes"
  type        = string
  default     = "ultrawarm1.medium.search"
}
