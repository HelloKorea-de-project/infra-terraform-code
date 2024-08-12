resource "aws_s3_bucket" "raw_layer" {
  bucket = "${var.project_name}-raw-layer"
}

resource "aws_s3_object" "raw_layer_source" {
  bucket = aws_s3_bucket.raw_layer.id
  key    = "source/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "stage_layer" {
  bucket = "${var.project_name}-stage-layer"
}

resource "aws_s3_object" "stage_layer_source" {
  bucket = aws_s3_bucket.stage_layer.id
  key    = "source/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "test_zone" {
  bucket = "${var.project_name}-test-zone"
}

resource "aws_s3_object" "test_zone_source" {
  bucket = aws_s3_bucket.test_zone.id
  key    = "source/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "temp_zone" {
  bucket = "${var.project_name}-temp-zone"
}

resource "aws_s3_object" "temp_zone_source" {
  bucket = aws_s3_bucket.temp_zone.id
  key    = "source/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "airflow_log" {
  bucket = "${var.project_name}-airflow-log"
}

resource "aws_s3_object" "airflow_log_directory" {
  bucket = aws_s3_bucket.airflow_log.id
  key    = "logs/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state"
}

resource "aws_s3_object" "terraform_state_directory" {
  bucket = aws_s3_bucket.terraform_state.id
  key    = "state/"
  content_type = "application/x-directory"
}


resource "aws_s3_bucket" "airflow_dags_bucket" {
  bucket = "${var.project_name}-airflow-dags"
  
}

resource "aws_s3_object" "dags_directory" {
  bucket = aws_s3_bucket.airflow_dags_bucket.id
  key    = "dags/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "plugins_directory" {
  bucket = aws_s3_bucket.airflow_dags_bucket.id
  key    = "plugins/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "tests_directory" {
  bucket = aws_s3_bucket.airflow_dags_bucket.id
  key    = "tests/"
  content_type = "application/x-directory"
}

resource "aws_s3_object" "dbt_directory" {
  bucket = aws_s3_bucket.airflow_dags_bucket.id
  key    = "dbt/"
  content_type = "application/x-directory"
}


resource "aws_s3_bucket" "external_zone" {
  bucket = "${var.project_name}-external-zone"
}

resource "aws_s3_object" "external_zone_source" {
  bucket = aws_s3_bucket.external_zone.id
  key    = "source/"
  content_type = "application/x-directory"
}

resource "aws_s3_bucket" "extra_data_zone" {
  bucket = "${var.project_name}-extra-data-zone"
}

resource "aws_s3_object" "extra_data_source" {
  bucket = aws_s3_bucket.extra_data_zone.id
  key    = "source/"
  content_type = "application/x-directory"
}

# Block public access for all buckets
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  count = 8

  bucket = [
    aws_s3_bucket.raw_layer.id,
    aws_s3_bucket.stage_layer.id,
    aws_s3_bucket.test_zone.id,
    aws_s3_bucket.temp_zone.id,
    aws_s3_bucket.airflow_log.id,
    aws_s3_bucket.terraform_state.id,
    aws_s3_bucket.airflow_dags_bucket.id,
    aws_s3_bucket.external_zone.id,
    aws_s3_bucket.extra_data_zone.id
  ][count.index]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}