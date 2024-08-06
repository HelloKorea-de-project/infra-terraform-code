variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where Redshift will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the subnets where Redshift will be deployed"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "The IDs of the subnets where Redshift will be deployed"
  type        = list(string)
}

variable "basic_ec2_ami" {
  description = "The AMI to use for the EC2 instances"
  type        = string
  default     = "ami-062cf18d655c0b1e8"
}

variable "airflow_ec2_ami" {
  description = "The AMI to use for the EC2 instances"
  type        = string
  default     = "ami-03c2773543a74f517"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
  default = "hellokorea-airflow-dags"
  
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "production_redshift_host" {
  description = "The hostname of the production Redshift cluster"
  type        = string
  default = "hellokorea-redshift-cluster.cvkht4jvd430.ap-northeast-2.redshift.amazonaws.com"
}

variable "production_redshift_user" {
  description = "The username for the production Redshift cluster"
  type        = string
  # tfvars에서 설정한 redshift_master_username을 사용
}

variable "production_redshift_password" {
  description = "The password for the production Redshift cluster"
  type        = string
  # tfvars에서 설정한 redshift_master_password을 사용 
}

variable "production_redshift_db" {
  description = "The name of the production Redshift database"
  type        = string
  default     = "hellokorea_db"
}