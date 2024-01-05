variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "instace_name" {
  description = "AWS EC2 Instance Name"
  type        = string
  default     = "instace_name"
}

variable "key_name" {
  description = "AWS EC2 Key Name"
  type        = string
  default     = "ec2"
}

variable "domain" {
  description = "Domain Name"
  type        = string
  default     = "andrerochadev.com.br"
}

variable "subdomain" {
  description = "Sub Domain Name"
  type        = string
  default     = "subdomain"
}