#VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Name" = "vpc"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags = {
    "Name" = "eip"
  }
}

#INTERNET GATEWAY
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "name" = "igw"
  }
}

#NAT GATEWAY
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubnet-1.id
  tags = {
    "Name" = "nat"
  }
  depends_on = [aws_internet_gateway.igw]
}


#SUBNETS
resource "aws_subnet" "pubnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az1
  tags = {
    "Name" = "pubnet-1"
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
resource "aws_subnet" "pubnet-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.az2
  tags = {
    "Name" = "pubnet-2"
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
resource "aws_subnet" "privnet-1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az1
  tags = {
    "Name" = "privnet-1"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
resource "aws_subnet" "privnet-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.az2
  tags = {
    "Name" = "privnet-2"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}
#################################

#ROUTE TABLE
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "rt-private" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

#ROUTE TABLE ASSOCIATION
resource "aws_route_table_association" "pub-rt-ass-1" {
  route_table_id = aws_route_table.rt-public.id
  subnet_id      = aws_subnet.pubnet-1.id
}

resource "aws_route_table_association" "priv-rt-ass-1" {
  route_table_id = aws_route_table.rt-private.id
  subnet_id      = aws_subnet.privnet-1.id
}
resource "aws_route_table_association" "pub-rt-ass-2" {
  route_table_id = aws_route_table.rt-public.id
  subnet_id      = aws_subnet.pubnet-2.id
}

resource "aws_route_table_association" "priv-rt-ass-2" {
  route_table_id = aws_route_table.rt-private.id
  subnet_id      = aws_subnet.privnet-2.id
}
########################################