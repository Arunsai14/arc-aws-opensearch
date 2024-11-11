# variables.tf

variable "vpc_id" {
  description = "VPC ID to allow network access."
  type        = string
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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ingress_rules" {
  description = "A list of ingress rules for the security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "egress_rules" {
  description = "A list of egress rules for the security group."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}