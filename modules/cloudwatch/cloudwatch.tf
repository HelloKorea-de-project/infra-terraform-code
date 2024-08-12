resource "aws_cloudwatch_event_rule" "daily_start_instances" {
  name                = "${var.project_name}_daily_start_instances"
  schedule_expression = "cron(30 3 ? * * *)" 
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_start_instances.name
  target_id = "${var.project_name}StartInstances"
  arn       = var.lambda_start_instances_arn
}

resource "aws_cloudwatch_event_rule" "daily_start_database" {
  name                = "${var.project_name}_daily_start_database"
  schedule_expression = "cron(20 3 ? * * *)" 
}


resource "aws_cloudwatch_event_target" "lambda_database_target" {
  rule      = aws_cloudwatch_event_rule.daily_start_database.name
  target_id = "${var.project_name}StartDatabase"
  arn       = var.lambda_start_database_arn
}