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