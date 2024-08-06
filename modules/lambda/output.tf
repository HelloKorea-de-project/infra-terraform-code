output "start_instances_arn" {
  value = aws_lambda_function.start_instances.arn
  description = "arn of the Lambda function that starts stopped instances"
}

output "start_database_arn" {
  value = aws_lambda_function.start_database.arn
  description = "arn of the Lambda function that starts the database"
  
}