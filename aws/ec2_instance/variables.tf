variable "aws_region" {
    description = "AWS Region"
    type        = string
    default     = "us-east-2"
}

variable "ec2_instace_name" {
    description = "AWS EC2 Instance Name"
    type        = string
    default     = "ec2_instace_namea"
}

variable "aws_ec2_key_name" {
    description = "AWS EC2 Key Name"
    type        = string
    default     = "ec2"
}
