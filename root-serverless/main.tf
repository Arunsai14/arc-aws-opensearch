resource "aws_opensearchserverless_collection" "this" {
  name             = var.name
  description      = var.description
  standby_replicas = var.use_standby_replicas ? "ENABLED" : "DISABLED"
  type             = var.type
  tags             = var.tags
  depends_on       = [aws_opensearchserverless_security_policy.encryption]
}

resource "aws_opensearchserverless_security_policy" "encryption" {
  count       = var.create_encryption_policy ? 1 : 0
  name        = coalesce(var.encryption_policy_name, "${var.name}-encryption-policy")
  type        = "encryption"
  description = var.encryption_policy_description
  policy = jsonencode(merge(
    {
      "Rules" = [
        {
          "Resource"     = ["collection/${var.name}"]
          "ResourceType" = "collection"
        }
      ]
    },
    {
      "AWSOwnedKey" = true  
    }
  ))
}


# Public access policy
resource "aws_opensearchserverless_security_policy" "public_network" {
  count       = var.create_public_access ? 1 : 0
  name        = "${substr(var.name, 0, 28)}-public-policy"  # Limit to 28 characters for the suffix
  type        = "network"
  description = "Public access policy for ${var.name}"
  policy      = jsonencode([{
    "Rules" = [
      {
        "ResourceType" = "collection",
        "Resource"     = ["collection/${var.name}"]
      },
      {
        "ResourceType" = "dashboard",
        "Resource"     = ["collection/${var.name}"]
      }
    ],
    "AllowFromPublic" = true,
  }])
}

# Private access policy - this won't create if public access is enabled
resource "aws_opensearchserverless_security_policy" "private_network" {
  count       = var.create_private_access && !var.create_public_access ? 1 : 0  # it's only created if public access is disabled
  name        = "${substr(var.name, 0, 28)}-private-policy"
  type        = "network"
  description = "Private VPC access policy for ${var.name}"
  policy      = jsonencode([{
    "Rules" = [
      {
        "ResourceType" = "collection",
        "Resource"     = ["collection/${var.name}"]
      },
      {
        "ResourceType" = "dashboard",
        "Resource"     = ["collection/${var.name}"]
      }
    ],
    "AllowFromPublic" = false,
    "Sourcevpcs" = [aws_opensearchserverless_vpc_endpoint.this[0].id],
  }])
}

resource "aws_opensearchserverless_vpc_endpoint" "this" {
  count              = var.create_private_access && !var.create_public_access ? 1 : 0  # Only create VPC endpoint for private access
  name               = var.vpc_name
  subnet_ids         = var.vpc_subnet_ids
  vpc_id             = var.vpc_vpc_id
  security_group_ids = var.vpc_security_group_ids
}

resource "aws_opensearchserverless_access_policy" "this" {
  count       = var.create_access_policy ? 1 : 0
  name        = var.access_policy_name
  type        = "data"
  description = var.access_policy_description
  policy      = jsonencode([for rule in var.access_policy_rules : {
    Rules = [
      {
        ResourceType = rule.type == "collection" ? "collection" : "index"
        Resource     = rule.type == "collection" ? ["collection/${var.name}"] : [for index in rule.indexes : "index/${var.name}/${index}"]
        Permission   = [for permission in rule.permissions : lookup({
          "read"      = "aoss:ReadDocument",
          "write"     = "aoss:WriteDocument",
          "create"    = "aoss:CreateIndex",
          "delete"    = "aoss:DeleteIndex",
          "update"    = "aoss:UpdateIndex",
          "describe"  = "aoss:DescribeIndex",
          "*"         = "aoss:*",
          "create_coll" = "aoss:CreateCollectionItems",
          "delete_coll" = "aoss:DeleteCollectionItems",
          "update_coll" = "aoss:UpdateCollectionItems",
          "describe_coll" = "aoss:DescribeCollectionItems"
        }, permission, "aoss:*")]
      }
    ],
    Principal = rule.principals
  }])
}




resource "aws_opensearchserverless_lifecycle_policy" "this" {
  count       = var.create_data_lifecycle_policy ? 1 : 0
  name        = var.data_lifecycle_policy_name
  type        = "retention"
  description = var.data_lifecycle_policy_description
  policy      = jsonencode({
    Rules = [
      for rule in var.data_lifecycle_policy_rules : {
        ResourceType      = "index",
        Resource          = [for index in rule.indexes : "index/${var.name}/${index}"],
        MinIndexRetention = rule.retention != "Unlimited" ? rule.retention : null
      }
    ]
  })
}

resource "aws_opensearchserverless_security_config" "this" {
  count       = var.create_security_config ? 1 : 0
  name        = var.security_config_name
  description = var.security_config_description
  type        = "saml"
  saml_options {
    metadata        = file(var.saml_metadata)
    group_attribute = var.saml_group_attribute
    user_attribute  = var.saml_user_attribute
    session_timeout = var.saml_session_timeout
  }
}

##################
# Security Group
##################
resource "aws_security_group" "this" {
  count       = var.create_network_policy && var.network_policy_type != "AllPublic" && var.vpc_create_security_group ? 1 : 0
  name        = var.vpc_security_group_name
  description = var.vpc_security_group_description
  vpc_id      = var.vpc_vpc_id
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = flatten([for item in var.vpc_security_group_sources : [for source in item.sources : source] if item.type == "IPv4"])
    ipv6_cidr_blocks = flatten([for item in var.vpc_security_group_sources : [for source in item.sources : source] if item.type == "IPv6"])
    prefix_list_ids  = flatten([for item in var.vpc_security_group_sources : [for source in item.sources : source] if item.type == "PrefixLists"])
    security_groups  = flatten([for item in var.vpc_security_group_sources : [for source in item.sources : source] if item.type == "SGs"])
    description      = "Allow Inbound HTTPS Traffic"
  }
  tags = merge(
    var.tags,
    {
      Name : "${var.name}-sg"
    }
  )
}
