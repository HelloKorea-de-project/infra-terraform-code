resource "aws_glue_job" "spark_job" {
  name     = "${var.project_name}_serverless_spark_job"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/scripts/spark_script.py"
    python_version  = "3"
  }



  default_arguments = {
    "--job-language"         = "python"
    "--additional-python-modules"        = "faker,redshift_connector"
    "--job-bookmark-option"  = "job-bookmark-enable"
    "--python-modules-installer-option"  = "--upgrade"
    "--enable-job-insights"              = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"      = "true"
    "--spark-event-logs-path" = "s3://${aws_s3_bucket.glue_scripts.bucket}/spark-logs/"
  }
  execution_class           = "STANDARD"
  glue_version      = "3.0"  # Supports Spark 3.1
  worker_type       = "G.1X"
  number_of_workers = 10
  max_retries       = 1
  timeout           = 2880

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_glue_job" "spark_subjob" {
  name     = "${var.project_name}_serverless_spark_subjob"
  role_arn = aws_iam_role.glue_role.arn

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.glue_scripts.bucket}/scripts/spark_subscript.py"
    python_version  = "3"
  }



  default_arguments = {
    "--job-language"         = "python"
    "--additional-python-modules"        = "faker,redshift_connector"
    "--job-bookmark-option"  = "job-bookmark-enable"
    "--python-modules-installer-option"  = "--upgrade"
    "--enable-job-insights"              = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-spark-ui"      = "true"
    "--spark-event-logs-path" = "s3://${aws_s3_bucket.glue_scripts.bucket}/spark-logs/subjob-logs/"
  }
  execution_class           = "STANDARD"
  glue_version      = "3.0"  # Supports Spark 3.1
  worker_type       = "G.1X"
  number_of_workers = 10
  max_retries       = 1
  timeout           = 2880

  execution_property {
    max_concurrent_runs = 1
  }
}

resource "aws_iam_role" "glue_role" {
  name = "${var.project_name}_glue_spark_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy_attachment" "glue_console" {
  role       = aws_iam_role.glue_role.id
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
  
}

resource "aws_iam_role_policy_attachment" "redshift_access" {
  role       = aws_iam_role.glue_role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
  
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = aws_iam_role.glue_role.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue_s3_access"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-stage-layer",
          "arn:aws:s3:::${var.project_name}-stage-layer/*",
          "arn:aws:s3:::${var.project_name}-extra-data-zone",
          "arn:aws:s3:::${var.project_name}-extra-data-zone/*",
          "arn:aws:s3:::${var.project_name}-external-zone",
          "arn:aws:s3:::${var.project_name}-external-zone/*",
          "arn:aws:s3:::${var.project_name}-glue-scripts",
          "arn:aws:s3:::${var.project_name}-glue-scripts/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "glue_pass_role" {
  name = "${var.project_name}_glue_pass_role"
  role = aws_iam_role.glue_role.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::862327261051:role/hellokorea_glue_spark_role"
        }
    ]
})
}

resource "aws_s3_bucket" "glue_scripts" {
  bucket = "${var.project_name}-glue-scripts"
}

resource "aws_s3_object" "glue_scripts_directory" {
  bucket = aws_s3_bucket.glue_scripts.id
  key    = "scripts/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "glue_scripts_log_directory" {
  bucket = aws_s3_bucket.glue_scripts.id
  key    = "spark-logs/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "subglue_scripts_log_directory" {
  bucket = aws_s3_bucket.glue_scripts.id
  key    = "spark-logs/subjob-logs/"
  content_type = "application/x-directory"
}


resource "aws_s3_bucket_public_access_block" "glue_scripts" {
  bucket = aws_s3_bucket.glue_scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}