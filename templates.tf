data "template_file" "port" {
  template = <<EOF
{
  "containerPort": $${ContainerPort},
  "hostPort": $${HostPort}
}
EOF
  vars = {
    ContainerPort = var.port
    HostPort      = var.port
  }
}

data "template_file" "logging" {
  template = <<EOF
{
  "logDriver": "awslogs",
  "options": {
    "awslogs-region": "$${LogRegion}",
    "awslogs-group": "$${LogGroup}",
    "awslogs-stream-prefix": "$${LogPrefix}"
  }
}
EOF
  vars = {
    LogGroup  = "/ecs/${var.service_name}-${var.environment}"
    LogRegion = var.region
    LogPrefix = "ecs"
  }
}

data "template_file" "environment" {
  for_each = var.task_environment
  template = <<EOF
{
  "name": "$${Name}",
  "value": "$${Value}"
}
EOF
  vars = {
    Name  = each.key
    Value = each.value
  }
}

data "template_file" "secret" {
  for_each = var.task_secret
  template = <<EOF
{
  "name": "$${Name}",
  "valueFrom": "$${Value}"
}
EOF
  vars = {
    Name  = each.key
    Value = data.aws_ssm_parameter.main[each.key].arn
  }
}

locals {
  rendered_environment = [for v in data.template_file.environment : v.rendered]
  rendered_secret      = [for v in data.template_file.secret : v.rendered]
}