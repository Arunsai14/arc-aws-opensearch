variable "collection_name" {
  description = "The name of the OpenSearch collection."
  type        = string
}

variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
  default     = "dev"
}

variable "namespace" {
  type        = string
  description = "Namespace of the project, i.e. arc"
  default     = "arc"
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
}

variable "tags" {
  description = "Tags to assign to the OpenSearch collection."
  type        = map(string)
  default     = {}
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

variable "vpc_id" {
  description = "The VPC ID for the VPC endpoint."
  type        = string
  default   = null
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

# Variable declaration for encryption_policy_kms_key_arn
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