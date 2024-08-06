output "airflow_meta_rds_endpoint" {
  value       = aws_db_instance.airflow_meta_db.endpoint
  description = "The connection endpoint for the airflow meta db instance"
}

output "production_rds_endpoint" {
  value       = aws_db_instance.production_db.endpoint
  description = "The connection endpoint for the production db instance"
}

output "rds_instances_identifier" {
  value = [aws_db_instance.airflow_meta_db.identifier, aws_db_instance.production_db.identifier, aws_db_instance.test_db.identifier]
  description = "The ids of the RDS instances"
}