# ALBを作成
resource "aws_lb" "myecs" {
  name = join("-", [var.base_name, "alb"])
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.myecs_alb.id]
  subnets = data.aws_subnets.myecs_public.ids
}

# ALBリスナー
resource "aws_ib_listener" "myecs" {
  load_balancer_arn = aws_lb.myecs.arn
  port = "443"
  protocol = "HTTPS"
  certificate_arn = data.aws_acm_certificate.myecs.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.myecs.arn
  }
}

# ALBターゲットグループ
resource "aws_lb_target_group" "myecs" {
  name = join("-", [var.base_name, "tg"])

  protocol = "HTTP"
  protocol_version = "GRPC"
  port = 8080

  vpc_id = data.aws_vpc.myecs.id
  target_type = "ip"

  lifecycle {
    create_before_destory = true
  }
}

# ALBに設定するセキュリティグループ
resource "aws_security_group" "myecs_alb" {
  name = join("-", [var.base_name, "alb", "sg"])
  vpc_id = data.aws_vpc.myecs.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# タスク定義
resource "aws_ecs_task_definition" "myecs" {
  family = json("-", [var.base_name, "task", "definition"])
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  
  container_definitions = jsonencode([
    {
      name = "gRPC-server"
      image = "${data.aws_ecr_repository.myecs.repository_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name = "cloudwatch"
          region = var.region
          log_group_name = join("/",["ecs", var.base_name])
          log_stream_prefix = "grpc"
        }
      }
    },
    {
      name = "log-router"
      image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
      essential = true
      
      firelensConfigurations = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
          config-file-type = "file"
          config-file-value = "/fluent-bit/configs/parse-json.conf"
        }
      }
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-region = var.region
        awslogs-group = join("/", ["escs", var.base_name])
        awslogs-stream-prefix = "logger"
      }
    }
  ])

  execution_role_arn = aws_iam_role.myecs_task_execution_role.arn
  task_role_arn = aws_iam_role.myecs_task_role.arn
}
