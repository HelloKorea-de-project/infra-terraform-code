variable "project_name" {
  description = "The name of the project, used as a prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where Redshift will be deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "The IDs of the public subnets where Redshift will be deployed"
  type        = list(string)
  
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets where Redshift will be deployed"
  type        = list(string)
}

variable "cidr_blocks" {
  description = "The CIDR block of the VPC"
  type        = list(string)
  default = ["0.0.0.0/0"]
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

variable "redshift_node_type" {
  description = "The node type to be provisioned for the Redshift cluster"
  type        = string
  default     = "dc2.large"
}

variable "redshift_cluster_type" {
  description = "The cluster type to use"
  type        = string
  default     = "single-node"
}

variable "redshift_number_of_nodes" {
  description = "The number of compute nodes in the Redshift cluster"
  type        = number
  default     = 1
}

variable "sg_private_instances"{ 
  description = "ID of the security group for private instances"
  type        = string
}

variable "sg_bastion" {
  description = "ID of the security group for the bastion host"
  type        = string
}