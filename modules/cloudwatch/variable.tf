variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "lambda_start_instances_arn" {
  description = "The name of the Lambda function that starts stopped instances"
  type        = string
  
}

variable "lambda_start_database_arn" {
  description = "value of the Lambda function that starts the database"
  type        = string
}