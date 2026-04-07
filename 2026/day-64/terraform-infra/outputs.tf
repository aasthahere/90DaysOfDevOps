output "vpc_id" {
  description = "VPC Id"
  value       = aws_vpc.vpc_main.id
}

output "subnet_id" {
  description = "Public Subnet Id"
  value       = aws_subnet.subnet_main.id
}

output "instance_id" {
  description = "EC2 Instance Id"
  value       = aws_instance.my_instance.id
}

output "instance_public_ip" {
  description = "Public Ip of the EC2 Instance"
  value       = aws_instance.my_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 Instance"
  value       = aws_instance.my_instance.public_dns
}

output "security_group_id" {
  description = "Security Group Id"
  value       = aws_security_group.sg_main.id
}
