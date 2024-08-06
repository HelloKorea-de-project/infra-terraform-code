output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP address of the bastion host"
}

output "bastion_host" {
  value       = aws_instance.bastion.id
  description = "ID of the bastion host"
}

output "airflow_host" {
  value       = aws_instance.airflow.id
  description = "ID of the Airflow server"
}

output "dbt_server" {
  value = aws_instance.dbt_server.id
  description = "ID of the dbt server"
}

output "grafana_server" {
  value = aws_instance.grafana_server.id
  description = "ID of the Grafana server"
}

output "redis_server" {
  value = aws_instance.redis_server.id
  description = "ID of the Metabase server"
}


output "ec2_instances_id" {
  value = [aws_instance.bastion.id, aws_instance.redis_server.id, aws_instance.airflow.id, aws_instance.dbt_server.id, aws_instance.grafana_server.id, aws_instance.main_server.id, aws_instance.airflow_first_worker.id]
  description = "ID of all EC2 instances"
}

output "airflow_instances_id" {
  value = [aws_instance.airflow.id]
  description = "ID of the Airflow server"
}

output "bastion_ssh_private_key_command" {
  value = "aws ssm get-parameter --name \"$/{var.project_name}/ec2/bastion-key\" --with-decryption --query \"Parameter.Value\" --output text > ${var.project_name}-bastion-key.pem"
  description = "value of the command to retrieve the private key from SSM"
}

output "airflow_private_ip" {
  value       = aws_instance.airflow.private_ip
  description = "Private IP address of the Airflow server"
}

output "main_server_private_ip" {
  value       = aws_instance.main_server.private_ip
  description = "Private IP address of the main server"
}

output "private_ssh_private_key_command" {
  value = "aws ssm get-parameter --name '/${var.project_name}/ec2/private-key' --with-decryption --query 'Parameter.Value' --output text > ${var.project_name}-private-key.pem"
  description = "value of the command to retrieve the private key from SSM"
}

output "sg_private_instances"{ 
  value = aws_security_group.private_instances.id
  description = "ID of the security group for private instances"
}

output "sg_bastion" {
  value = aws_security_group.bastion.id
  description = "ID of the security group for the bastion host"
}
