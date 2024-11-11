####################################################################
################################################################
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the VPC for OpenSearch domain"
  type        = string
  default     = null
}

variable "route_table_ids" {
  description = "Route table IDs associated with the VPC"
  type        = list(string)
}

variable "security_group_name" {
  description = "Security group IDs for the VPC endpoint"
  type        = string
}

variable "network_type" {
  description = "Type of network access. Valid values are 'public' or 'vpc'."
  type        = string
  default     = "public"  # Default to public, but you can change it to 'vpc' as needed
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "collection_resource" {
  description = "The resource name to associate with the security policies."
  type        = string
}

variable "encryption_policy_name" {
  description = "Name for the encryption security policy."
  type        = string
  default     = "example-encryption-policy"
}

variable "vpc_security_policy_name" {
  description = "Name for the VPC access security policy."
  type        = string
  default     = "example-vpc-access-policy"
}

variable "public_security_policy_name" {
  description = "Name for the public access security policy."
  type        = string
  default     = "example-public-access-policy"
}

variable "collection_name" {
  description = "The name of the OpenSearch Serverless collection."
  type        = string
  default     = "example-collection"
}

variable "collection_description" {
  description = "Description for the OpenSearch Serverless collection."
  type        = string
  default     = "An example OpenSearch Serverless collection"
}

variable "standby_replicas" {
  description = "Indicates whether standby replicas should be used for a collection."
  type        = string
  default     = "ENABLED"
}


variable "collection_type" {
  description = "Type of collection (SEARCH, TIMESERIES, VECTORSEARCH)."
  type        = string
  default     = "TIMESERIES"
}

variable "public_access" {
  description = "Enable or disable public access for the OpenSearch collection."
  type        = bool
  default     = true
}

variable "aws_owned_key" {
  description = "Whether to use AWS owned encryption key for the encryption policy."
  type        = bool
  default     = true
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
