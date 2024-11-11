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
  default     = false
}

variable "encryption_policy_name" {
  description = "The name of the encryption policy."
  type        = string
}

variable "encryption_policy_description" {
  description = "The description of the encryption policy."
  type        = string
}

variable "create_network_policy" {
  description = "Flag to determine if network policy should be created."
  type        = bool
  default     = false
}

variable "network_policy_name" {
  description = "The name of the network policy."
  type        = string
}

variable "network_policy_description" {
  description = "The description of the network policy."
  type        = string
  default     = "Network policy description"
}

variable "vpce_name" {
  description = "The name of the VPC endpoint."
  type        = string
}

variable "vpce_subnet_ids" {
  description = "A list of subnet IDs for the VPC endpoint."
  type        = list(string)
}

variable "vpce_vpc_id" {
  description = "The VPC ID for the VPC endpoint."
  type        = string
}

variable "vpce_security_group_ids" {
  description = "A list of security group IDs for the VPC endpoint."
  type        = list(string)
}

variable "create_access_policy" {
  description = "Flag to determine if access policy should be created."
  type        = bool
  default     = false
}

variable "access_policy_name" {
  description = "The name of the access policy."
  type        = string
   default    = "arc_access_policy"
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
    indexes     = list(string)
    permissions = list(string)
    principals  = list(string)
  }))

}

variable "create_data_lifecycle_policy" {
  description = "Flag to determine if data lifecycle policy should be created."
  type        = bool
  default     = false
}

variable "data_lifecycle_policy_name" {
  description = "The name of the data lifecycle policy."
  type        = string
  default     = "data_lifecycle_policy"
}

variable "data_lifecycle_policy_description" {
  description = "The description of the data lifecycle policy."
  type        = string
   default     = "Data lifecycle policy description"
}

variable "data_lifecycle_policy_rules" {
  description = "List of rules for the data lifecycle policy."
  type        = list(object({
    indexes    = list(string)
    retention  = string
  }))
}

variable "create_security_config" {
  description = "Flag to determine if security configuration should be created."
  type        = bool
  default     = false
}

variable "security_config_name" {
  description = "The name of the security configuration."
  type        = string
  default     = "my_security_config"
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

variable "vpce_security_group_sources" {
  description = "List of security group sources for VPC endpoint."
  type        = list(object({
    type    = string
    sources = list(string)
  }))
}

variable "vpce_create_security_group" {
  description = "Flag to determine if a security group for VPC endpoint should be created."
  type        = bool
  default     = true
}

variable "vpce_security_group_name" {
  description = "The name of the VPC endpoint security group."
  type        = string
}

variable "vpce_security_group_description" {
  description = "The description of the VPC endpoint security group."
  type        = string
  default     = "Security group for VPC endpoint"
}

