data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20231207"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ec2_instace" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.aws_ec2_key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_ssh_http.id]
  subnet_id                   = aws_subnet.ec2_subnet.id
  depends_on                  = [aws_internet_gateway.gateway]

  tags = {
    Name = "ec2_instace-${var.ec2_instace_name}"
  }
}

resource "aws_vpc" "ec2_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "EC2 VPC"
  }
}

resource "aws_subnet" "ec2_subnet" {
  cidr_block        = cidrsubnet(aws_vpc.ec2_vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.ec2_vpc.id
  availability_zone = "us-east-2b"
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.ec2_vpc.id

  tags = {
    Name = "gateway-teste"
  }
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.ec2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "example"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.ec2_subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_main_route_table_association" "main_route_table_association" {
  vpc_id         = aws_vpc.ec2_vpc.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh"
  description = "Permite SSH e HTTP na instancia EC2"
  vpc_id      = aws_vpc.ec2_vpc.id

  ingress {
    description = "SSH to EC2"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP to EC2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS to EC2"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_and_http"
  }
}