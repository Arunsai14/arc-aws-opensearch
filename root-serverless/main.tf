##############################################
########   OpenSearch Serverless   ###########
##############################################

# AWS Caller Identity (to get the account ID)
data "aws_caller_identity" "current" {}

######## OpenSearch Security Group Options #######
resource "aws_security_group" "opensearch_sg" {
  name        = var.security_group_name
  description = "Security group for the OpenSearch Domain"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = var.tags
}

# VPC Endpoint for OpenSearch
resource "aws_vpc_endpoint" "opensearch" {
  vpc_id            = var.vpc_id  
  service_name      = "com.amazonaws.${var.region}.es" 
  route_table_ids   = var.route_table_ids
  security_group_ids = [aws_security_group.opensearch_sg.id]
   vpc_endpoint_type = "Interface"
  # Optionally enable private DNS
  private_dns_enabled = true
}

# Security Policy for VPC Access
resource "aws_opensearchserverless_security_policy" "vpc_security" {
  count  = var.network_type == "vpc" ? 1 : 0  # Only create this if network_type is 'vpc'
  name   = "example-vpc-access-policy"
  type   = "network"

  policy = jsonencode([{
    "SourceVPCEs" = [aws_vpc_endpoint.opensearch.id]  # Use the VPC ID instead of the endpoint ID
    "SourceServices" = ["es.amazonaws.com"]  # Specify the service for VPC access
    "Rules" = [
      {
        "ResourceType" = "collection"
        "Resource"     = ["collection/${var.collection_name}"]
      }
    ]
  }])
}

# Security Policy for Public Access (if public network type is selected)
resource "aws_opensearchserverless_security_policy" "public_security" {
  count = var.network_type == "public" ? 1 : 0  # Only create if network_type is 'public'
  name  = "example-public-access-policy"
  type  = "network"

  policy = jsonencode([{
    "AllowFromPublic" = true
    "Rules" = [
      {
        "ResourceType" = "collection"
        "Resource"     = [
          "collection/${var.collection_name}"
        ]
      }
    ]
  }])
}

# Encryption Policy for OpenSearch Collection
resource "aws_opensearchserverless_security_policy" "encryption_security" {
  name   = "example-encryption-policy"
  type   = "encryption"

  policy = jsonencode({
    "AWSOwnedKey" = true
    "Rules" = [
      {
        "ResourceType" = "collection"
        "Resource"     = ["collection/${var.collection_name}"]
      }
    ]
  })
}

# OpenSearch Serverless Collection
resource "aws_opensearchserverless_collection" "example" {
  name             = var.collection_name
  description      = var.collection_description
  standby_replicas = var.standby_replicas
  tags             = var.tags
  type             = var.collection_type

  depends_on = [
    aws_opensearchserverless_security_policy.public_security,
    aws_opensearchserverless_security_policy.vpc_security,
    aws_opensearchserverless_security_policy.encryption_security
  ]
}
