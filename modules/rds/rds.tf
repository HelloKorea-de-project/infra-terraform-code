resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-RDS-Subnet-Group"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.sg_private_instances, var.sg_bastion]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-RDS-Security-Group"
  }
}

resource "aws_db_instance" "airflow_meta_db" {
  identifier             = "${var.project_name}-airflow-meta-db"
  engine                 = "postgres"
  engine_version         = "13.15"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "airflow_meta_db"
  username               = var.metadata_db_id
  password               = var.metadata_db_pw
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-Airflow-meta-RDS-Instance"
  }
}

resource "aws_iam_role" "rds_role" {
  name = "${var.project_name}_rds_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "rds_s3_access" {
  name = "${var.project_name}_rds_s3_access"
  role = aws_iam_role.rds_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.project_name}-stage-layer",
          "arn:aws:s3:::${var.project_name}-stage-layer/*",
          "arn:aws:s3:::${var.project_name}-external-zone",
          "arn:aws:s3:::${var.project_name}-external-zone/*"
        ]
      }
    ]
  })
}

resource "aws_db_instance_role_association" "test_db_role_association" {
  db_instance_identifier = aws_db_instance.test_db.identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.rds_role.arn
}

resource "aws_db_instance_role_association" "production_db_role_association" {
  db_instance_identifier = aws_db_instance.production_db.identifier
  feature_name           = "s3Import"
  role_arn               = aws_iam_role.rds_role.arn
}

resource "aws_db_instance" "production_db" {
  identifier             = "${var.project_name}-production-db"
  engine                 = "postgres"
  engine_version         = "13.15"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "production_db"
  username               = var.production_db_id
  password               = var.production_db_pw
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true



  tags = {
    Name = "${var.project_name}-Production-RDS-Instance"
  }
}

resource "aws_db_subnet_group" "test_rds_subnet_group" {
  name       = "${var.project_name}-test-rds-subnet-group"
  subnet_ids = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-RDS-Subnet-Group"
  }
}

resource "aws_security_group" "test_rds_sg" {
  name        = "test-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-RDS-Security-Group"
  }
}

resource "aws_db_instance" "test_db" {
  identifier             = "${var.project_name}-test-db"
  engine                 = "postgres"
  engine_version         = "13.15"
  instance_class         = "db.t3.small"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "test_db"
  username               = var.production_db_id
  password               = var.production_db_pw
  db_subnet_group_name   = aws_db_subnet_group.test_rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.test_rds_sg.id]
  publicly_accessible    = true
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-Production-RDS-Instance"
  }
}
