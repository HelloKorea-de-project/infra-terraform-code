provider "aws" {
  region = "ap-northeast-2"
}

terraform {
  backend "s3" {
    bucket = "hellokorea-terraform-state"
    key    = "state/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "aws_caller_identity" "current" {}

module "network" {
  source = "./modules/network"
  project_name = var.project_name
  
}

module "s3" {
  source = "./modules/s3"
  project_name = var.project_name
}

module "ec2" {
  source = "./modules/ec2"
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_region = var.aws_region
  production_redshift_user = var.redshift_master_username
  production_redshift_password = var.redshift_master_password
}

module "rds" {
  source = "./modules/rds"
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  sg_private_instances = module.ec2.sg_private_instances
  sg_bastion = module.ec2.sg_bastion
  metadata_db_id = var.metadata_db_id
  metadata_db_pw = var.metadata_db_pw
  production_db_id = var.production_db_id
  production_db_pw = var.production_db_pw
}

module "redshift" {
  source = "./modules/redshift"
  project_name = var.project_name
  vpc_id = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  sg_private_instances = module.ec2.sg_private_instances
  sg_bastion = module.ec2.sg_bastion
  redshift_master_username = var.redshift_master_username
  redshift_master_password = var.redshift_master_password
}

module "lambda" {
  source = "./modules/lambda"
  project_name = var.project_name
  s3_bucket_id = module.s3.s3_dags_bucket
  s3_bucket_arn = module.s3.s3_dags_bucket_arn
  airflow_instances_id = module.ec2.airflow_instances_id
  daily_start_instances_trigger_arn = module.cloudwatch.daily_start_instances_trigger_arn
  daily_start_database_trigger_arn = module.cloudwatch.daily_start_database_trigger_arn
  ec2_instances_id = module.ec2.ec2_instances_id
  rds_instances_identifier = module.rds.rds_instances_identifier
  redshift_clusters_identifier = module.redshift.redshift_clusters_identifier

}

module "cloudwatch" {
  source = "./modules/cloudwatch"
  project_name = var.project_name
  lambda_start_instances_arn = module.lambda.start_instances_arn
  lambda_start_database_arn = module.lambda.start_database_arn

}

module "glue" {
  source = "./modules/glue"
  project_name = var.project_name
}