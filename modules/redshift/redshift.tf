
resource "aws_redshift_cluster" "hello_korea_redshift_cluster" {
  cluster_identifier  = "${var.project_name}-redshift-cluster"
  database_name       = "${var.project_name}_db"
  master_username     = var.redshift_master_username
  master_password     = var.redshift_master_password
  node_type           = var.redshift_node_type
  cluster_type        = var.redshift_cluster_type
  number_of_nodes     = var.redshift_number_of_nodes
  iam_roles = [aws_iam_role.redshift_s3_access.arn]

  skip_final_snapshot = false 


  vpc_security_group_ids = [aws_security_group.redshift.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.hello_korea_redshift_subnet_group.name

}

# Redshift Subnet Group
resource "aws_redshift_subnet_group" "hello_korea_redshift_subnet_group" {
  name       = "${var.project_name}-redshift-subnetgroup"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name} redshift subnet group"
  }
}

# Security Group for Redshift
resource "aws_security_group" "redshift" {
  name        = "${var.project_name}-redshift-sg"
  description = "Security group for Redshift cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound from VPC"
    from_port       = 5439
    to_port         = 5439
    protocol        = "tcp"
    security_groups = [var.sg_private_instances, var.sg_bastion]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create schemas using null_resource
resource "null_resource" "create_schemas" {
  depends_on = [aws_redshift_cluster.hello_korea_redshift_cluster]

  provisioner "local-exec" {
    command = <<-EOF
      set PGPASSWORD=${var.redshift_master_password} 
      psql -h ${aws_redshift_cluster.hello_korea_redshift_cluster.endpoint} \
      -p 5439 \
      -U ${var.redshift_master_username} \
      -d ${aws_redshift_cluster.hello_korea_redshift_cluster.database_name} \
      -c "CREATE SCHEMA IF NOT EXISTS raw; CREATE SCHEMA IF NOT EXISTS analytics; CREATE SCHEMA IF NOT EXISTS test; CREATE SCHEMA IF NOT EXISTS dimension;"
    EOF
  }
}

resource "aws_iam_role" "redshift_s3_access" {
  name = "${var.project_name}_redshift_s3_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "redshift.amazonaws.com"
        }
      }
    ]
  })
}

# S3 접근을 위한 정책 생성
resource "aws_iam_role_policy" "redshift_s3_access_policy" {
  name = "${var.project_name}_redshift_s3_access_policy"
  role = aws_iam_role.redshift_s3_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-stage-layer",
          "arn:aws:s3:::${var.project_name}-stage-layer/*",
          "arn:aws:s3:::${var.project_name}-external-zone",
          "arn:aws:s3:::${var.project_name}-external-zone/*",
          "arn:aws:s3:::${var.project_name}-extra-data-zone",
          "arn:aws:s3:::${var.project_name}-extra-data-zone/*"
        ]
      }
    ]
  })
}

resource "aws_redshift_cluster" "hello_korea_test_redshift_cluster" {
  cluster_identifier  = "${var.project_name}-test-redshift-cluster"
  database_name       = "${var.project_name}_db"
  master_username     = var.redshift_master_username
  master_password     = var.redshift_master_password
  node_type           = var.redshift_node_type
  cluster_type        = var.redshift_cluster_type
  number_of_nodes     = var.redshift_number_of_nodes
  iam_roles = [aws_iam_role.redshift_s3_access.arn]

  skip_final_snapshot = false 

  publicly_accessible = true
  

  vpc_security_group_ids = [aws_security_group.test_redshift.id]
  cluster_subnet_group_name = aws_redshift_subnet_group.hello_korea_test_redshift_subnet_group.name

}

resource "aws_redshift_subnet_group" "hello_korea_test_redshift_subnet_group" {
  name       = "${var.project_name}-test-redshift-subnetgroup"
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "${var.project_name} redshift subnet group"
  }
}

resource "aws_security_group" "test_redshift" {
  name        = "${var.project_name}-test-redshift-sg"
  description = "Security group for Redshift cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow inbound from VPC"
    from_port       = 5439
    to_port         = 5439
    protocol        = "tcp"
    cidr_blocks     = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "test_create_schemas" {
  depends_on = [aws_redshift_cluster.hello_korea_test_redshift_cluster]

  provisioner "local-exec" {
    command = <<-EOF
      set PGPASSWORD=${var.redshift_master_password} 
      psql -h ${aws_redshift_cluster.hello_korea_test_redshift_cluster.endpoint} \
      -p 5439 \
      -U ${var.redshift_master_username} \
      -d ${aws_redshift_cluster.hello_korea_test_redshift_cluster.database_name} \
      -c "CREATE SCHEMA IF NOT EXISTS raw; CREATE SCHEMA IF NOT EXISTS analytics; CREATE SCHEMA IF NOT EXISTS test;"
    EOF
  }
}