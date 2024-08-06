output "daily_start_instances_trigger_arn" {
  value = aws_cloudwatch_event_rule.daily_start_instances.arn
  description = "arn of the CloudWatch event rule for starting instances"
}

output "daily_start_database_trigger_arn" {
  value = aws_cloudwatch_event_rule.daily_start_database.arn
  description = "arn of the CloudWatch event rule for starting the database"
  
}