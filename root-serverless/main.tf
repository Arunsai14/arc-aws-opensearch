##############################################
########   OpenSearch Serverless   ###########
##############################################
data "aws_caller_identity" "current" {}

resource "aws_opensearchserverless_security_policy" "example" {
  name   = var.encryption_policy_name
  type   = "encryption"
  policy = jsonencode({
    "Rules" = [
      {
        "Resource"    = [var.collection_resource],
        "ResourceType" = "collection"
      }
    ],
    "AWSOwnedKey" = var.aws_owned_key
  })
}

# resource "aws_opensearchserverless_security_policy" "vpc_security" {
#   name   = var.vpc_security_policy_name
#   type   = "network"
#   policy = jsonencode({
#     "Rules" = [
#       {
#         "Resource"    = [var.collection_resource],
#         "ResourceType" = "collection"
#       }
#     ],
#     "VPC" = {
#       "VpcId" = var.vpc_id
#     }
#   })
# }

# resource "aws_opensearchserverless_security_policy" "public_security" {
#   name = "example-public-access-policy"
#   type = "network"  # Use "network" for public network access policy

#   policy = jsonencode([
#     {
#       "AllowFromPublic" = true             
#       "SourceServices" = ["es.amazonaws.com"]  
#       "Rules" = [
#         {
#           "ResourceType" = "collection" 
#           "Resource" = [
#             "arn:aws:opensearchserverless:${var.region}:${data.aws_caller_identity.current.account_id}:collection/${var.collection_name}"
#           ]
#         }
#       ]
#     }
#   ])
# }

resource "aws_opensearchserverless_security_policy" "public_security" {
  name = "example-public-access-policy"
  type = "network"  # Use "network" for public network access policy

  policy = jsonencode([{
    "SourceServices" = ["es"]
    "Rules" = [
      {
        "ResourceType" = "collection"  # Resource type is collection for OpenSearch Serverless
        "Resource"     = [
          "collection/${var.collection_name}"  # Reference your collection with correct pattern
        ]
      }
    ]
  }])
}


resource "aws_opensearchserverless_collection" "example" {
  name             = var.collection_name
  description      = var.collection_description
  standby_replicas = var.standby_replicas
  tags             = var.tags
  type             = var.collection_type

  depends_on = [
    aws_opensearchserverless_security_policy.example,
    aws_opensearchserverless_security_policy.public_security
  ]
}
