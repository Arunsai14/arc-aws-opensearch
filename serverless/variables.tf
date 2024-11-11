variable "name" {
  description = "The name of the OpenSearch domain."
  type        = string
}

variable "description" {
  description = "The description of the OpenSearch domain."
  type        = string
}

variable "use_standby_replicas" {
  description = "Flag to specify whether standby replicas are used."
  type        = bool
}

variable "type" {
  description = "The type of OpenSearch domain (e.g., `dedicated`, `standard`)."
  type        = string
}

variable "create_encryption_policy" {
  description = "Flag to create encryption policy."
  type        = bool
}

variable "encryption_policy_name" {
  description = "The name of the encryption policy."
  type        = string
}

variable "encryption_policy_description" {
  description = "Description for the encryption policy."
  type        = string
}

variable "vpce_name" {
  description = "The name of the VPC endpoint."
  type        = string
}

variable "vpce_vpc_id" {
  description = "The VPC ID to create the VPC endpoint."
  type        = string
}

variable "vpce_security_group_ids" {
  description = "A list of security group IDs associated with the VPC endpoint."
  type        = list(string)
}
