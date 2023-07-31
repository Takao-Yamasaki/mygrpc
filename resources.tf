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
    create_before_destroy = true
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
  family = join("-", [var.base_name, "task", "definition"])
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu = 256
  memory = 512
  
  container_definitions = jsonencode([
    {
      name = "gRPC-server"
      image = "${data.aws_ecr_repository.myecs.repository_url}:${var.image_tag}"
      essential = true
      port_mappings = [
        {
          containerPort = 8080
          hostPort = 8080
        }
      ]
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name = "cloudwatch"
          region = var.region
          log_group_name = join("/", ["ecs", var.base_name])
          log_stream_prefix = "grpc"
        }
      }
    },
    {
      name = "log-router"
      image = "public.ecr.aws/aws-observability/aws-for-fluent-bit:stable"
      essential = true

      firelens_configurations = {
        type = "fluentbit"
        options = {
          enable-ecs-log-metadata = "true"
          config-file-type = "file"
          config-file-value = "/fluent-bit/configs/parse-json.conf"
        }
      }
      log_configuration = {
        log_driver = "awslogs"
        options = {
          awslogs-region = var.region
          awslogs-group = join("/", ["ecs", var.base_name])
          awslogs-stream-prefix = "logger"
        }
      }
    }
  ])

  execution_role_arn = aws_iam_role.myecs_task_execution_role.arn
  task_role_arn = aws_iam_role.myecs_task_role.arn
}


# タスク実行ロール
resource "aws_iam_role" "myecs_task_execution_role" {
  name = join("-", [var.base_name,"execution-role"])
  assume_role_policy = data.aws_iam_policy_document.myecs_task_execution_assume_policy.json
}

data "aws_iam_policy_document" "myecs_task_execution_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "myecs_task_execution_policy" {
  role = aws_iam_role.myecs_task_execution_role.name
  policy_arn = "arn:aws:iam:aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# タスクロール
resource "aws_iam_role" "myecs_task_role" {
  name = json("-", [var.base_name, "role"])
  assume_role_policy = data.aws_iam_policy_document.myecs_task_assume_policy.json
}

data "aws_iam_policy_document" "myecs_task_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals{
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "myecs_task_policy" {
  name = join("-", [var.base_name, "policy"])
  policy = data.aws_iam_policy_document.myecs_task_policy.json
}

data "aws_iam_policy_document" "myecs_task_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:DescribeLogStream",
      "logs:PutLogEvents",
    ]
    effect = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "myecs_task_role" {
  role = aws_iam_role.myecs_task_role.name
  policy = aws_iam_policy.myecs_task_policy.arn
}

# サービス定義
resource "aws_ecs_service" "myecs" {
  name = join("-", [var.base_name, "service"])
  cluster = aws_ecs_cluster.myecs.id
  
  task_definition = aws_ecs_taskdefinition.myecs.arn
  desierd_count = 1
  launch_type = "FARGATE"
  
  depends_on = [aws_lb_listener.myecs]

  # タスクコンテナをどのALBのターゲットグループに指定するか
  load_balancer {
    target_group_arn = aws_lb_target_group_myecs.arn
    container_name = "gRPC-server"
    container_port = "8080"
  }

  network_configuration {
    subnets = data.aws_subnets.myecs_private.ids
    security_groups = [aws_security_group.myecs_service.id]
    assign_public_ip = false
  }
}

# タスクコンテナにどんなセキュリティグループを指定するか

resource "aws_security_group" "myecs_service" {
  name = join("-", [var.base_name, "service", "sg"])
  vpc_id = data.aws_vpc.myecs.id
  
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group = [aws_security_group.myecs_alb.id]
  }
}

# クラスターの設定
# 全タスクをFargate上で稼働させるようにした

resource "aws_ecs_cluster" "myecs" {
  name = join("-", [var.base_name, "clucter"])
}

resource "aws_ecs_cluster_capacity_providers" "myecs" {
  cluster_name = aws_ecs_cluster.myecs.name

  capacity_providers = ["FARGATE"]
  
  default_capacity_provider_strategy {
    base = 1
    weight = 100
    capacity_provider = "FARGATE"
  }
}
