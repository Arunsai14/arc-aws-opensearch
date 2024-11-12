variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"  # Change as needed
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



variable "vpc_name" {
  description = "The name of the VPC endpoint."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID to create the VPC endpoint."
  type        = string
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs associated with the VPC endpoint."
  type        = list(string)
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

