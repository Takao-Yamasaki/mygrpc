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

# パブリックサブネットの作成
resource "aws_subnet" "myecs_public" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "myecs_public"
  }
}

# プライベートサブネットの作成
resource "aws_subnet" "myecs_private" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "myecs_private"
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

# パブリックサブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.myecs_public.id
  route_table_id = aws_route_table.myecs_route_table.id
}
