# modules/opensearch_serverless/outputs.tf

output "opensearch_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = aws_opensearchserverless_collection.example.arn
}

output "collection_endpoint" {
  description = "Endpoint for interacting with the OpenSearch collection"
  value       = aws_opensearchserverless_collection.example.collection_endpoint
}

output "dashboard_endpoint" {
  description = "Endpoint for accessing OpenSearch Dashboards"
  value       = aws_opensearchserverless_collection.example.dashboard_endpoint
}
