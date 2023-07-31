# ALBを動かしたいVPCの設定
data "aws_vpc" {
  id = var.vpc_id
}

# ALBを動かしたいパブリックサブネットの設定
data "aws_subnets" "myecs_public" {
  vpc_id = var.aws_vpc.id
}

# ALBを動かしたいプライベートサブネットの設定
data "aws_subnets" "myecs_private" {
  id = var.private_subnet.id
}

# ACM証明書
data "aws_acm_certificacte" "myecs" {
  domain = var.domain_name
  # 有効な証明書のみを検索
  statuses = ["ISSUED"]
}

# ECRリポジトリ
data "aws_ecr_repository" "myecs" {
  name = var.ecr_repo_name
}
