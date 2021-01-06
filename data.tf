# ALB used listener
data "aws_lb" "main" {
  name = var.alb_name
}

# Get listener HTTPS from ALB
data "aws_lb_listener" "main" {
  load_balancer_arn = data.aws_lb.main.arn
  port              = 443
}

# Simply specify the family to find the latest ACTIVE revision in that family.
data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.main.family
  depends_on = [ aws_ecs_task_definition.main ]
}

# Get Parameter from variable
data "aws_ssm_parameter" "main" {
  for_each = var.task_secret
  name     = each.value
}