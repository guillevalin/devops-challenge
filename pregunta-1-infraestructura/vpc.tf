provider "aws" {
  region = "us-east-1"
}

# Crear la VPC con un bloque CIDR /16
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Crear un Internet Gateway para las subnets públicas
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# Crear un Elastic IP para el NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

# Crear una subnet pública en us-east-1a
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.0.0/18"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

# Crear una subnet pública en us-east-1b
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.64.0/18"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# Crear una subnet privada en us-east-1a
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.128.0/18"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-1"
  }
}

# Crear una subnet privada en us-east-1b
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.192.0/18"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-2"
  }
}

# Crear el NAT Gateway en una de las subnets públicas
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "main-nat-gateway"
  }
}

# Crear la tabla de rutas para las subnets públicas
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Crear la tabla de rutas para las subnets privadas
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Asociar las subnets públicas a la tabla de rutas pública
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Asociar las subnets privadas a la tabla de rutas privada
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}