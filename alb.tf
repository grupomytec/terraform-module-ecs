# Target Group to App
resource "aws_alb_target_group" "main" {
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval  = var.tg_interval
    path      = var.tg_path
    timeout   = var.tg_timeout
    matcher   = var.tg_matcher
    healthy_threshold   = var.tg_healthy_threshold
    unhealthy_threshold = var.tg_unhealthy_threshold
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Redirect all traffic from the ALB to the target group
resource "aws_lb_listener_rule" "main" {
  listener_arn = data.aws_lb_listener.main.arn
  priority     = var.listener_priority
  
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.main.arn
  }

  condition {
    host_header {
      values = [var.host_header]
    }
  }

  dynamic "condition" {
    for_each = length(var.path_pattern) > 0 ? [true] : []
    content {
      path_pattern {
        values = [var.path_pattern]
      }
    }
  }

}