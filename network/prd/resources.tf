provider "aws" {
  region = "ap-northeast-1"
}

# VPCの作成
resource "aws_vpc" "myecs" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "myecs"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "myecs_igw" {
  vpc_id = aws_vpc.myecs.id

  tags = {
    Name = "myecs_igw"
  }
}

# パブリックサブネットの作成(1)
resource "aws_subnet" "myecs_public_1" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.1.0/24"
  # 起動されるEC2には、パブリックIPが自動的に割り当てられる
  map_public_ip_on_launch = true
  
  tags = {
    Name = "myecs_public_1"
    Type = "Public"
  }
}

# パブリックサブネットの作成(2)
resource "aws_subnet" "myecs_public_2" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.2.0/24"
  # 起動されるEC2には、パブリックIPが自動的に割り当てられる
  map_public_ip_on_launch = true
  
  tags = {
    Name = "myecs_public_2"
    Type = "Public"
  }
}

# プライベートサブネットの作成(1)
resource "aws_subnet" "myecs_private_1" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "myecs_private_1"
    Type = "Private"
  }
}

# プライベートサブネットの作成(2)
resource "aws_subnet" "myecs_private_2" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "myecs_private_2"
    Type = "Private"
  }
}

# ルートテーブルの作成
resource "aws_route_table" "myecs_route_table" {
  vpc_id = aws_vpc.myecs.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myecs_igw.id
  }

  tags = {
    Name = "myecs_route_table"
  }
}

# パブリックサブネットとルートテーブルの関連付け(1)
resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.myecs_public_1.id
  route_table_id = aws_route_table.myecs_route_table.id
}

# パブリックサブネットとルートテーブルの関連付け(2)
resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.myecs_public_2.id
  route_table_id = aws_route_table.myecs_route_table.id
}
