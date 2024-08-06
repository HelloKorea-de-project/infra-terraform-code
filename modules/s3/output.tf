output "s3_raw_layer_bucket" {
  value       = aws_s3_bucket.raw_layer.id
  description = "The id of the raw layer S3 bucket"
}

output "s3_stage_layer_bucket" {
  value       = aws_s3_bucket.stage_layer.id
  description = "The id of the stage layer S3 bucket"
}

output "s3_test_zone_bucket" {
  value       = aws_s3_bucket.test_zone.id
  description = "The id of the test zone S3 bucket"
}

output "s3_temp_zone_bucket" {
  value       = aws_s3_bucket.temp_zone.id
  description = "The id of the temp zone S3 bucket"
}

output "s3_airflow_log_bucket" {
  value       = aws_s3_bucket.airflow_log.id
  description = "The id of the Airflow log S3 bucket"
}

output "s3_terraform_state_bucket" {
  value       = aws_s3_bucket.terraform_state.id
  description = "The id of the Terraform state S3 bucket"
}

output "s3_dags_bucket" {
  value       = aws_s3_bucket.airflow_dags_bucket.id
  description = "The id of the Airflow DAGs S3 bucket"
}

output "s3_dags_bucket_arn" {
  value       = aws_s3_bucket.airflow_dags_bucket.arn
  description = "The ARN of the Airflow DAGs S3 bucket"
}
