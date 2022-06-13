#######################################################################
# Layer I -- Network
# This Terraform File will create components that related to AWS VPC (Virtual Private Cloud):
#
# 1. VPC
# 2. Internet Gateway for VPC
# 3. Two Public Subnets with Route Tables to Internet Gateway
# 4. Two NAT gateways with Elastic IPs which will be atached to private subnets
# 5. Two Private Subnets with Route Tables to NAT Gateway
#######################################################################

provider "aws" {
  region = "us-east-1"
}


#######################################################################
# VPC creation with Internet Gateway for public subnets
#######################################################################

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
    Project = "${var.env}-exercise"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
    Project = "${var.env}-exercise"
  }
}


#######################################################################
# Public Subnet #1 creation with Route Table
#######################################################################


resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  depends_on = [aws_internet_gateway.main]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-subnet-1"
    Project = "${var.env}-exercise"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
    Project = "${var.env}-exercise"
  }
}

resource "aws_route_table_association" "public-subnet-1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_subnets.id
}

#######################################################################
# Public Subnet #2 creation with Route Table
#######################################################################

resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.21.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  depends_on = [aws_internet_gateway.main]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-public-subnet-2"
    Project = "${var.env}-exercise"
  }
}

resource "aws_route_table_association" "public-subnet-2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_subnets.id
}

#######################################################################
# NAT Gateway with Elastic IPs creation
#######################################################################

resource "aws_eip" "elastic_ip_1" {
  vpc      = true
  tags = {
      Name = "${var.env}-elastic-ip-1"
      Project = "${var.env}-exercise"
  }
}

resource "aws_nat_gateway" "main_1" {
  allocation_id = aws_eip.elastic_ip_1.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "${var.env}-NAT-Gateway-1"
    Project = "${var.env}-exercise"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "elastic_ip_2" {
  vpc      = true
  tags = {
      Name = "${var.env}-nat-gw-2"
      Project = "${var.env}-exercise"
  }
}

resource "aws_nat_gateway" "main_2" {
  allocation_id = aws_eip.elastic_ip_2.id
  subnet_id     = aws_subnet.public_subnet_2.id

  tags = {
    Name = "${var.env}-NAT-Gateway-2"
    Project = "${var.env}-exercise"
  }

  depends_on = [aws_internet_gateway.main]
}

#######################################################################
# Private Subnet creation with NAT & Route Table
#######################################################################

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.env}-private-subnet-1"
    Project = "${var.env}-exercise"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "${var.env}-private-subnet-2"
    Project = "${var.env}-exercise"
  }
}

#######################################################################
# Route Tables association to Private Subnets
#######################################################################


resource "aws_route_table" "private_subnets_1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_1.id
  }
  tags = {
    Name = "${var.env}-route-private-subnets"
    Project = "${var.env}-exercise"
  }
}

resource "aws_route_table_association" "private-subnet-1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_subnets_1.id
}



resource "aws_route_table" "private_subnets_2" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_2.id
  }
  tags = {
    Name = "${var.env}-route-private-subnets"
    Project = "${var.env}-exercise"
  }
}

resource "aws_route_table_association" "private-subnet-2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_subnets_2.id
}

#######################################################################
