##############################################
########   OpenSearch Serverless   ###########
##############################################
data "aws_caller_identity" "current" {}

resource "aws_opensearchserverless_security_policy" "vpc_security" {
  count  = var.network_type == "vpc" ? 1 : 0  # Only create this if network_type is 'vpc'
  name   = "example-vpc-access-policy"
  type   = "network"
  
  policy = jsonencode({
    "Rules" = [
      {
        "ResourceType" = "collection"
        "Resource"     = ["collection/${var.collection_name}"]
      }
    ],
    "VPC" = {
      "VpcId" = var.vpc_id 
    }
  })
}

resource "aws_opensearchserverless_security_policy" "public_security" {
  count = var.network_type == "public" ? 1 : 0
  name = "example-public-access-policy"
  type = "network" 

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



resource "aws_opensearchserverless_collection" "example" {
  name             = var.collection_name
  description      = var.collection_description
  standby_replicas = var.standby_replicas
  tags             = var.tags
  type             = var.collection_type

  depends_on = [
    aws_opensearchserverless_security_policy.example,
    # aws_opensearchserverless_security_policy.encryption_security,
    aws_opensearchserverless_security_policy.public_security,
    aws_opensearchserverless_security_policy.vpc_security
  ]
}
