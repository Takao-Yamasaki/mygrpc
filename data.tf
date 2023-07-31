# TODO: 設定を記述すること
# ALBを動かしたいVPCの設定
data "aws_vpc" {
  
}

# TODO: 設定を記述すること
# ALBを動かしたいパブリックサブネットの設定
data "aws_subnets" "myecs_public" {
  
}

# TODO: 設定を記述すること
# ALBを動かしたいプライベートサブネットの設定
data "aws_subnet" "myecs_provate" {
  
}

data "aws_acm_certificacte" "myecs" {
  domain = var.domain_name
}
