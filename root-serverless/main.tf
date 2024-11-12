data "aws_caller_identity" "current" {}

resource "aws_opensearchserverless_collection" "this" {
  name             = var.collection_name
  description      = var.description
  standby_replicas = var.use_standby_replicas ? "ENABLED" : "DISABLED"
  type             = var.type
  tags             = var.tags
  depends_on       = [aws_opensearchserverless_security_policy.encryption]
}

resource "aws_opensearchserverless_security_policy" "encryption" {
  count       = var.create_encryption_policy ? 1 : 0
  name        = "${var.collection_name}-encryption"
  type        = "encryption"
  description = "Encryption policy for OpenSearch collection"
  policy = jsonencode(merge(
    {
      "Rules" = [
        {
          "Resource"     = ["collection/${var.collection_name}"]
          "ResourceType" = "collection"
        }
      ],
    },
    {
      "AWSOwnedKey" = true  
    }
  ))
}


# Public access policy
resource "aws_opensearchserverless_security_policy" "public_network" {
  count       = var.create_public_access ? 1 : 0
  name        = "${var.collection_name}-public" 
  type        = "network"
  description = "Public access policy for ${var.collection_name}"
  policy      = jsonencode([{
    "Rules" = [
      {
        "ResourceType" = "collection",
        "Resource"     = ["collection/${var.collection_name}"]
      },
      {
        "ResourceType" = "dashboard",
        "Resource"     = ["collection/${var.collection_name}"]
      },
    ],
    "AllowFromPublic" = true,
  }])
}

resource "aws_opensearchserverless_security_policy" "private_network" {
  count       = var.create_private_access && !var.create_public_access ? 1 : 0 
  name        = "${var.collection_name}-private-policy"
  type        = "network"
  description = "Private VPC access policy for ${var.collection_name}"
  policy      = jsonencode([{
    "Rules" = [
      {
        "ResourceType" = "collection",
        "Resource"     = ["collection/${var.collection_name}"]
      },
      {
        "ResourceType" = "dashboard",
        "Resource"     = ["collection/${var.collection_name}"]
      }
    ],
    "AllowFromPublic" = false,
    "SourceVPCEs" = [aws_opensearchserverless_vpc_endpoint.this[0].id],
  }])
}

resource "aws_opensearchserverless_vpc_endpoint" "this" {
  count              = var.create_private_access && !var.create_public_access ? 1 : 0 
  name               = var.vpc_name
  subnet_ids         = var.vpc_subnet_ids
  vpc_id             = var.vpc_id
  security_group_ids = [aws_security_group.this[0].id]
}


resource "aws_iam_role" "opensearch_access_role" {
  count = var.create_access_policy ? 1 : 0 
  name = "${var.collection_name}-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "es.amazonaws.com"  
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "opensearch_custom_policy" {
  count = var.create_access_policy ? 1 : 0 
  name        = "${var.collection_name}-os-custompolicy"
  description = "Custom policy for OpenSearch Serverless access"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "aoss:ReadDocument",
          "aoss:WriteDocument",
          "aoss:DescribeIndex",
          "aoss:*"
        ],
        "Resource": "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "opensearch_access_policy_attachment" {
  count      = var.create_access_policy ? 1 : 0 
  role       = aws_iam_role.opensearch_access_role[0].name
  policy_arn = aws_iam_policy.opensearch_custom_policy[0].arn 
} 

resource "aws_opensearchserverless_access_policy" "this" {
  count       = var.create_access_policy ? 1 : 0
  name        = "${var.collection_name}-access"
  type        = "data"
  description = "Network policy description"

  # Define the policy with required permissions
  policy = jsonencode([
    for rule in var.access_policy_rules : {
      "Rules" = [
        {
          "ResourceType" = rule.resource_type
          "Resource"     = rule.resource
          "Permission"   = rule.permissions
        }
      ],
    "Principal" = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.opensearch_access_role[0].name}"
    ]
  }])
}

resource "aws_opensearchserverless_lifecycle_policy" "this" {
  count       = var.create_data_lifecycle_policy ? 1 : 0
  name        = "${var.collection_name}-data"
  type        = "retention"
  description = "Data lifecycle policy description"
  policy      = jsonencode({
    Rules = [
      for rule in var.data_lifecycle_policy_rules : {
        ResourceType      = "index",
        Resource          = [for index in rule.indexes : "index/${var.collection_name}/${index}"],
        MinIndexRetention = rule.retention != "Unlimited" ? rule.retention : null
      }
    ]
  })
}


##################
# Security Group
##################
resource "aws_security_group" "this" {
  count       = var.create_network_policy && var.network_policy_type != "AllPublic" && var.vpc_create_security_group ? 1 : 0
  name        = var.vpc_security_group_name
  description = "Security group for the OpenSearch collection"
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


# resource "aws_opensearchserverless_lifecycle_policy" "this" {
#   count       = var.create_data_lifecycle_policy ? 1 : 0
#   name        = var.data_lifecycle_policy_name
#   type        = "retention"
#   description = "Data lifecycle policy description"
  
#   policy = jsonencode({
#     Rules = [
#       for rule in var.data_lifecycle_policy_rules : {
#         ResourceType      = "index",
#         Resource          = var.global_resource,  # Use global resource variable
#         MinIndexRetention = var.global_retention
#       }
#     ]
#   })
# }
