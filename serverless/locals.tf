locals {
    access_policy_rules = [
  {
    resource_type = "collection"
    resource      = ["collection/arc-public"]
    permissions   = ["aoss:CreateCollectionItems", "aoss:DeleteCollectionItems", "aoss:UpdateCollectionItems", "aoss:DescribeCollectionItems"]
  },
]

data_lifecycle_policy_rules = [
  {
    indexes    = ["index1", "index2"]
    retention  = "30d"
  },
  {
    indexes    = ["index3"]
    retention  = "24h"
  }
]

}