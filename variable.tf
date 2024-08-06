variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
  default     = "hellokorea" 
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
  description = "value"
  type = string
}

variable "metadata_db_id" {
  description = "The id of the metadata database"
  type        = string
  
}

variable "metadata_db_pw" {
  description = "The password of the metadata database"
  type        = string
  
}

variable "production_db_id" {
  description = "The id of the production database"
  type        = string
  
}

variable "production_db_pw" {
  description = "The password of the production database"
  type        = string
  
}

variable "redshift_master_username" {
  description = "The master username for Redshift"
  type        = string
  
}

variable "redshift_master_password" {
  description = "The master password for Redshift"
  type        = string
  sensitive   = true
  
}