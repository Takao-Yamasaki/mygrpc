# ALBを動かしたいVPCの設定
# data "aws_vpc" "myecs" {
#   id = "vpc-0f081979fb819d695"
# }

# ALBを動かしたいパブリックサブネットの設定
# data "aws_subnets" "myecs_public" {
#   vpc_id = "vpc-0f081979fb819d695"
# }

# # ALBを動かしたいプライベートサブネットの設定
# data "aws_subnets" "myecs_private" {
#   id = "subnet-0d82c9806de5a8f43"
# }

# # ACM証明書
# data "aws_acm_certificate" "myecs" {
#   domain = "zackzack.link"
#   # 有効な証明書のみを検索
#   statuses = ["ISSUED"]
# }

# ECRリポジトリ
data "aws_ecr_repository" "myecs" {
  name = "mygrpc"
}

variable "base_name" {
  type = string
  default = "myecs"
}

# ALBを動かしたいVPCの設定
variable "id" {
  type = string
  default = "vpc-0f081979fb819d695"
}

# ALBを動かしたいパブリックサブネットの設定
variable "vpc_id" {
  type = string
  default = "vpc-0f081979fb819d695"
}
