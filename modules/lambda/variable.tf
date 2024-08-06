variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
  default = "airflow_sync_function"
}

variable "airflow_instances_id" {
  type        = list(string)
  description = "The ID of the Airflow instance"
}


variable "s3_bucket_id" {
  type        = string
  description = "The ID of the S3 bucket"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default = "hellokorea-airflow-dags"
  
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket"
}

variable "daily_start_instances_trigger_arn" {
  description = "The ARN of the CloudWatch trigger that starts instances daily"
  type        = string
}

variable "daily_start_database_trigger_arn" {
  description = "value of the CloudWatch trigger that starts the database daily"
  type        = string
}

variable "ec2_instances_id" {
  description = "The ID of the EC2 instances"
  type        = list(string)
}

variable "rds_instances_identifier" {
  description = "The ID of the RDS instances"
  type        = list(string)
}

variable "redshift_clusters_identifier" {
  description = "The ID of the Redshift clusters"
  type        = list(string)
}