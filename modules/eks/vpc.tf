# 1 vpc, 1 public subnet , 1 private subnet, 1 eip, 1 nat gateway, 1 IGW, 1 route table, 1 security group

locals {
  cluster-name = var.cluster-name
}

resource "aws_vpc" "customer-vpc" {
  cidr_block = var.cidr-block
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc-name
    Env = var.env
  }
}

resource "aws_internet_gateway" "customer-igw" {
  vpc_id = aws_vpc.customer-vpc.id

  tags = {
    Name = var.igw-name
    env  = var.env
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
  }

  depends_on = [ aws_vpc.customer-vpc ]
}

resource "aws_subnet" "public-subnet" {
  count                   = var.pub-subnet-count
  vpc_id                  = aws_vpc.customer-vpc.id
  cidr_block              = element(var.pub-cidr-block, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.pub-availability-zone, count.index)

  tags = {
    Name                                          = "${var.pub-sub-name}-${count.index + 1}"
    Env                                           = var.env
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }

  depends_on = [ aws_vpc.customer-vpc ]
}

resource "aws_subnet" "private-subnet" {
  count                   = var.pri-subnet-count
  vpc_id                  = aws_vpc.customer-vpc.id
  cidr_block              = element(var.pri-cidr-block, count.index)
  map_public_ip_on_launch = false
  availability_zone       = element(var.pri-availability-zone, count.index)

  tags = {
    Name                                          = "${var.pri-sub-name}-${count.index + 1}"
    Env                                           = var.env
    "kubernetes.io/cluster/${local.cluster-name}" = "owned"
    "kubernetes.io/role/elb"                      = "1"
  }

  depends_on = [ aws_vpc.customer-vpc ]
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.customer-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.customer-igw.id
  }

  tags = {
    Name = var.public-rt-name
    Env  = var.env
  }

  depends_on = [ aws_vpc.customer-vpc ]
  
}

resource "aws_route_table_association" "public-rt-association" {
  count          = var.pub-subnet-count
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-rt.id

  depends_on = [ aws_vpc.customer-vpc, aws_subnet.public-subnet ]
}

resource "aws_eip" "ngw-eip" {
  domain = "vpc"

  tags = {
    Name = var.eip-name
  }

  depends_on = [ aws_internet_gateway.customer-igw ]
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags = {
    Name = var.ngw-name
  }

  depends_on = [ aws_vpc.customer-vpc, aws_eip.ngw-eip ]
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.customer-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = var.private-rt-name
    Env  = var.env
  }

  depends_on = [ aws_vpc.customer-vpc ]
  
}

resource "aws_route_table_association" "private-rt-association" {
  count          = 3
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-rt.id

  depends_on = [ aws_vpc.customer-vpc, aws_subnet.private-subnet ]
}

resource "aws_security_group" "eks-cluster-sg" {
  name        = var.eks-sg
  description = "Alow 443 from Jump server"
  vpc_id      = aws_vpc.customer-vpc.id

  ingress {
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
    Name = var.eks-sg
  }

}