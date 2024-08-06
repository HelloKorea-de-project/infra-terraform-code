output "redshift_endpoint" {
  value       = aws_redshift_cluster.hello_korea_redshift_cluster.endpoint
  description = "The endpoint of the Redshift cluster"
}

output "redshift_port" {
  value       = 5439
  description = "The port of the Redshift cluster"
}

output "redshift_database_name" {
  value       = aws_redshift_cluster.hello_korea_redshift_cluster.database_name
  description = "The name of the Redshift database"
}

output "redshift_clusters_identifier" {
  value       = [aws_redshift_cluster.hello_korea_redshift_cluster.cluster_identifier, aws_redshift_cluster.hello_korea_test_redshift_cluster.cluster_identifier]
  description = "The id of the Redshift cluster"
  
}