locals {
  additional_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_vpc" "eks-vpc" {
    cidr_block = var.vpc_cidr
    tags = var.tags
    enable_dns_hostnames = true
    enable_dns_support = true
}

resource "aws_subnet" "pub-sn1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 10)
    availability_zone = "us-east-1a"
  tags = var.tags
}

resource "aws_subnet" "pub-sn2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 20)
    availability_zone = "us-east-1b"
  tags = var.tags
}

resource "aws_subnet" "pri-sn1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 110)
    availability_zone = "us-east-1a"
  tags = merge(var.tags, local.additional_tags)
}

resource "aws_subnet" "pri-sn2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, 120)
    availability_zone = "us-east-1b"
  tags = merge(var.tags, local.additional_tags)
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.eks-vpc.id
    tags = var.tags
}

resource "aws_eip" "eip1" {
    domain = "vpc"
  tags = var.tags
  depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_nat_gateway" "eks-nat" {
    allocation_id = aws_eip.eip1.id
    subnet_id = aws_subnet.pub-sn1.id
    tags = var.tags

    depends_on = [ aws_internet_gateway.igw ]
}

resource "aws_route_table" "pub_rt1" {
    vpc_id = aws_vpc.eks-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = var.tags

}

resource "aws_route_table" "pri_rt1" {
    vpc_id = aws_vpc.eks-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.eks-nat.id
    }
  tags = var.tags
}

resource "aws_route_table_association" "pub_rt1-1" {
    subnet_id = aws_subnet.pub-sn1.id
    route_table_id = aws_route_table.pub_rt1.id
  
}

resource "aws_route_table_association" "pub_rt1-2" {
    subnet_id = aws_subnet.pub-sn2.id
    route_table_id = aws_route_table.pub_rt1.id
  
}

resource "aws_route_table_association" "pri_rt1-1" {
    subnet_id = aws_subnet.pri-sn1.id
    route_table_id = aws_route_table.pub_rt1.id
  
}

resource "aws_route_table_association" "pri_rt1-2" {
    subnet_id = aws_subnet.pri-sn2.id
    route_table_id = aws_route_table.pub_rt1.id
  
}