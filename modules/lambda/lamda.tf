

data "archive_file" "s3sync_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/sync_function"
  output_path = "${path.module}/lambda_function/sync_function.zip"
}


resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}_s3_ec2_sync_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_ssm_instances_access" {
  name = "${var.project_name}_lambda_instances_access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:StartInstances",
          "s3:GetObject",
          "s3:ListBucket",
          "rds:StartDBInstance",
          "rds:DescribeDBInstances",
          "redshift:ResumeCluster",
          "redshift:DescribeClusters"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "s3_access"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:HeadObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}



resource "aws_lambda_function" "sync_function" {
  filename         = data.archive_file.s3sync_zip.output_path
  function_name    = "${var.project_name}_s3_ec2_sync_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "sync_function.lambda_handler"
  source_code_hash = data.archive_file.s3sync_zip.output_base64sha256
  runtime          = "python3.11"
  timeout          = 200

  environment {
    variables = {
      AIRFLOW_INSTANCES_ID = jsonencode(var.airflow_instances_id)
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.sync_function.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }

}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sync_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}


data "archive_file" "start_instances_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/start_instances_function"
  output_path = "${path.module}/lambda_function/start_instances_function.zip"
}

resource "aws_lambda_function" "start_instances" {
  filename      = data.archive_file.start_instances_zip.output_path
  function_name = "${var.project_name}_start_instances"
  role          = aws_iam_role.lambda_role.arn
  handler       = "start_instances_function.lambda_handler"
  runtime       = "python3.12"
  source_code_hash = data.archive_file.start_instances_zip.output_base64sha256
  timeout       = 200

  environment {
    variables = {
      EC2_INSTANCES = jsonencode(var.ec2_instances_id)
    }
  }
}


resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_instances.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.daily_start_instances_trigger_arn
}


data "archive_file" "start_database_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/start_database_function"
  output_path = "${path.module}/lambda_function/start_database_function.zip"
}

resource "aws_lambda_function" "start_database" {
  filename      = data.archive_file.start_database_zip.output_path
  function_name = "${var.project_name}_start_database"
  role          = aws_iam_role.lambda_role.arn
  handler       = "start_database_function.lambda_handler"
  runtime       = "python3.12"
  source_code_hash = data.archive_file.start_database_zip.output_base64sha256
  timeout       = 200

  environment {
    variables = {
      RDS_INSTANCES = jsonencode(var.rds_instances_identifier)
      REDSHIFT_CLUSTERS = jsonencode(var.redshift_clusters_identifier)
    }
  }
}

resource "aws_lambda_permission" "allow_database_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_database.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.daily_start_database_trigger_arn
}