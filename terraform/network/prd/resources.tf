provider "aws" {
  region = "ap-northeast-1"
}

# VPCの作成
resource "aws_vpc" "myecs" {
  cidr_block = "10.0.0.0/16"
  # DNSサーバーによる名前解決の有効化
  enable_dns_support = true
  # パブリックDNSホスト名の自動割り当て
  enable_dns_hostnames = true

  # タグの設定
  tags = {
    Name = "myecs"
  }
}

# パブリックサブネットの作成(1a)
resource "aws_subnet" "myecs_public_1a" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.1.0/24"
  # 起動されるEC2には、パブリックIPが自動的に割り当てられる
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1a"
  
  tags = {
    Name = "myecs_public_1a"
    Type = "Public"
  }
}

# パブリックサブネットの作成(1c)
resource "aws_subnet" "myecs_public_1c" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.2.0/24"
  # 起動されるEC2には、パブリックIPが自動的に割り当てられる
  map_public_ip_on_launch = true
  availability_zone = "ap-northeast-1c"
  
  tags = {
    Name = "myecs_public_1c"
    Type = "Public"
  }
}

# プライベートサブネットの作成(1a)
resource "aws_subnet" "myecs_private_1a" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.10.0/24"
  # パブリックIPは不要
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "myecs_private_1a"
    Type = "Private"
  }
}

# プライベートサブネットの作成(1c)
resource "aws_subnet" "myecs_private_1c" {
  vpc_id = aws_vpc.myecs.id
  cidr_block = "10.0.20.0/24"
  # パブリックIPは不要
  map_public_ip_on_launch = false
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "myecs_private_1c"
    Type = "Private"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "myecs_igw" {
  vpc_id = aws_vpc.myecs.id

  tags = {
    Name = "myecs_igw"
  }
}

# EIP(1a)
resource "aws_eip" "myecs_nat_1a" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.myecs_igw]
  tags = {
    Name = "myecs_nat_1a"
  }
}

# NATゲートウェイ(1a)
resource "aws_nat_gateway" "myecs_nat_1a" {
  allocation_id = aws_eip.myecs_nat_1a.id
  subnet_id = aws_subnet.myecs_public_1a.id
  depends_on = [aws_internet_gateway.myecs_igw]
  
  tags = {
    Name = "myecs_nat_1a"
  }

}

# EIP(1c)
resource "aws_eip" "myecs_nat_1c" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.myecs_igw]
  tags = {
    Name = "myecs_nat_1c"
  }
}

# NATゲートウェイ(1c)
resource "aws_nat_gateway" "myecs_nat_1c" {
  allocation_id = aws_eip.myecs_nat_1c.id
  subnet_id = aws_subnet.myecs_public_1c.id
  depends_on = [aws_internet_gateway.myecs_igw]
  tags = {
    Name = "myecs_nat_1c"
  }
}

# ルートテーブルの作成
resource "aws_route_table" "myecs_route_table" {
  vpc_id = aws_vpc.myecs.id

  tags = {
    Name = "myecs_route_table"
  }
}

# ルートの設定
resource "aws_route" "myecs_route" {
  route_table_id = aws_route_table.myecs_route_table.id
  gateway_id = aws_internet_gateway.myecs_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# パブリックサブネットとルートテーブルの関連付け(1a)
resource "aws_route_table_association" "public_1a" {
  subnet_id = aws_subnet.myecs_public_1a.id
  route_table_id = aws_route_table.myecs_route_table.id
}

# パブリックサブネットとルートテーブルの関連付け(1c)
resource "aws_route_table_association" "public_1c" {
  subnet_id = aws_subnet.myecs_public_1c.id
  route_table_id = aws_route_table.myecs_route_table.id
}

# Private用ルートテーブルの作成(1a)
resource "aws_route_table" "myecs_route_table_private_1a" {
  vpc_id = aws_vpc.myecs.id

  tags = {
    Name = "myecs_route_table_private_1a"
  }
}

# Private用ルートテーブルの作成(1c)
resource "aws_route_table" "myecs_route_table_private_1c" {
  vpc_id = aws_vpc.myecs.id

  tags = {
    Name = "myecs_route_table_private_1c"
  }
}

# Private用ルートの設定(1a)
resource "aws_route" "myecs_route_1a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.myecs_route_table_private_1a.id
  nat_gateway_id = aws_nat_gateway.myecs_nat_1a.id
}

# Private用ルートの設定(1c)
resource "aws_route" "myecs_route_1c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.myecs_route_table_private_1c.id
  nat_gateway_id = aws_nat_gateway.myecs_nat_1c.id
}

# プライベートサブネットとルートテーブルの関連付け(1a)
resource "aws_route_table_association" "myecs_private_1a" {
  subnet_id = aws_subnet.myecs_private_1a.id
  route_table_id = aws_route_table.myecs_route_table_private_1a.id
}

# プライベートサブネットとルートテーブルの関連付け(1c)
resource "aws_route_table_association" "myecs_private_1c" {
  subnet_id = aws_subnet.myecs_private_1c.id
  route_table_id = aws_route_table.myecs_route_table_private_1c.id
}
