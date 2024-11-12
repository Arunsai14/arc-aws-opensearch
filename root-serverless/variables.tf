variable "name" {
  description = "The name of the OpenSearch collection."
  type        = string
}

variable "description" {
  description = "A description for the OpenSearch collection."
  type        = string
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

variable "encryption_policy_name" {
  description = "The name of the encryption policy."
  type        = string
}

variable "encryption_policy_description" {
  description = "Description of the encryption policy"
  type        = string
  default     = "Encryption policy for OpenSearch collection"
}

variable "create_network_policy" {
  description = "Flag to determine if network policy should be created."
  type        = bool
  default     = true
}

variable "network_policy_name" {
  description = "The name of the network policy."
  type        = string
  default   = null
}

variable "network_policy_description" {
  description = "The description of the network policy."
  type        = string
  default     = "Network policy description"
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

variable "access_policy_name" {
  description = "The name of the access policy."
  type        = string
   default    = "arc-access-policy"
}

variable "access_policy_description" {
  description = "The description of the access policy."
  type        = string
  default     = "Network policy description"
}

variable "access_policy_rules" {
  description = "List of rules for the access policy."
  type        = list(object({
    type        = string
    indexes     = optional(list(string), [])
    permissions = list(string)
    principals  = list(string)
  }))
  default = []
}

variable "create_data_lifecycle_policy" {
  description = "Flag to determine if data lifecycle policy should be created."
  type        = bool
  default     = false
}

variable "data_lifecycle_policy_name" {
  description = "The name of the data lifecycle policy."
  type        = string
  default     = "data-lifecycle-policy"
}

variable "data_lifecycle_policy_description" {
  description = "The description of the data lifecycle policy."
  type        = string
   default     = "Data lifecycle policy description"
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

variable "security_config_description" {
  description = "The description of the security configuration."
  type        = string
  default     = "Security config description"
}

variable "saml_metadata" {
  description = "The path to the SAML metadata file."
  type        = string
  default     = ""
}

variable "saml_group_attribute" {
  description = "The SAML attribute that represents groups."
  type        = string
  default     = "group"
}

variable "saml_user_attribute" {
  description = "The SAML attribute that represents users."
  type        = string
  default     = "user"
}

variable "saml_session_timeout" {
  description = "The session timeout for the SAML configuration."
  type        = string
  default     = "3600"
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