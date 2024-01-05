output "subdomain" {
  value       = aws_route53_record.subdomain.fqdn
  description = "Fully Qualified Domain Name of the EC2 Instance"
}

output "public_dns" {
  value       = aws_instance.ec2_instace.public_dns
  description = "Public DNS of the EC2 Instance"
}

output "public_ip" {
  value       = aws_instance.ec2_instace.public_ip
  description = "Public IP of the EC2 Instance"
}