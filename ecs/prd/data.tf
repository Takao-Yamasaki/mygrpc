# ALBを動かしたいVPCの設定
data "aws_vpc" "myecs" {
  # TODO: ネットワーク作成後手入力すること
  id = "vpc-03d11da613fed0e43"
}

# ルートテーブル
data "aws_route_table" "myecs_route_table" {
  vpc_id = data.aws_vpc.myecs.id

  tags = {
    Name = "myecs_route_table"
  }
}

# ALBを動かしたいパブリックサブネットの設定
# TypeタグがPublicのサブネットをフィルタリング
data "aws_subnets" "myecs_public" {
  # VPCIDを元にサブネットをフィルタリング
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.myecs.id]
  }

  filter {
    name = "tag:Type"
    values = ["Public"]
  }
}

# ALBを動かしたいプライベートサブネットの設定
# TypeタグがPrivateのサブネットをフィルタリング
data "aws_subnets" "myecs_private" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.myecs.id]
  }
  filter {
    name = "tag:Type"
    values = ["Private"]
  }
}

# ACM証明書
data "aws_acm_certificate" "myecs" {
  domain = "zackzack.link"
  # 有効な証明書のみを検索
  statuses = ["ISSUED"]
}

# ECRリポジトリ
data "aws_ecr_repository" "myecs" {
  name = var.ecr_repo_name
}

# base_name
variable "base_name" {
  type = string
  default = "myecs"
}

# リージョン
variable "region" {
  type = string
  default = "ap-northeast-1"
}

# タグ
variable "image_tag" {
  type = string
  default = "latest"
}

variable "ecr_repo_name" {
  type = string
  default = "myecs"
}
