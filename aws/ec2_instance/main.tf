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
  key_name                    = var.key_name
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_ssh_http.id]
  subnet_id                   = aws_subnet.ec2_subnet.id
  depends_on                  = [aws_internet_gateway.gateway]

  tags = {
    Name = var.instace_name
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
  availability_zone = "${var.aws_region}b"
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
    Name = "route_table"
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

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.ec2_instace.id
  domain   = "vpc"
  
  tags = {
    Name = "elastic_ip"
  }
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

  ingress {
    description = "HTTP 8080 to EC2"
    from_port   = 8080
    to_port     = 8080
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

# resource "aws_route53domains_registered_domain" "domain" {
#   domain_name = "andrerocha.site."

#   name_server {
#     name = "ns-937.awsdns-53.net"
#   }

#   name_server {
#     name = "ns-1564.awsdns-03.co.uk"
#   }

#   name_server {
#     name = "ns-505.awsdns-63.com"
#   }

#   name_server {
#     name = "ns-1185.awsdns-20.org"
#   }
# }

# resource "aws_route53_zone" "dev" {
#   name = "${var.subdomain}.${var.domain}"

#   tags = {
#     Environment = var.subdomain
#   }
# }

resource "aws_route53_record" "subdomain-ns" {
  zone_id = "Z0290689XCPP4TLLJYLQ"
  name    = "${var.subdomain}.${var.domain}"
  type    = "NS"
  ttl     = "30"
  records = [aws_eip.elastic_ip.public_ip]
}
