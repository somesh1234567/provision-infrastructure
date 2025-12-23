# 1 vpc, 1 subnet and 1 security group for the application

resource "aws_vpc" "somesh_vpc" {
  cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
  tags = {
    Name = "somesh-vpc"
  }
}

resource "aws_subnet" "somesh_subnet" {
  vpc_id                  = aws_vpc.somesh_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "somesh-subnet"
  }
}

resource "aws_security_group" "somesh_sg" {
  name        = "somesh-sg"
  description = "Security group for somesh application"
  vpc_id      = aws_vpc.somesh_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}