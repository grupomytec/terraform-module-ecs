# CloudWatch Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.service_name}-${var.environment}"
  retention_in_days = 90
  tags              = var.tags
}

# Metric Alarm Target Unhealthy
resource "aws_cloudwatch_metric_alarm" "target_unhealthy" {
  #actions_enabled     = "true"
  #alarm_actions       = ["arn:aws:sns:sa-east-1:184730703936:NotifyFacilita"]
  alarm_name          = "${var.service_name}-${var.environment}-Target_Group_Unhealthy"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm = "1"

  dimensions = {
    TargetGroup  = aws_alb_target_group.main.arn_suffix
    LoadBalancer = data.aws_lb.main.arn_suffix
  }

  evaluation_periods = "1"
  metric_name        = "UnHealthyHostCount"
  namespace          = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Maximum"
  threshold          = var.min_capacity
  treat_missing_data = "missing"
}

# Metric Alarm Request
resource "aws_cloudwatch_metric_alarm" "request_count" {
  alarm_name          = "${var.service_name}-${var.environment}-RequestCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  alarm_actions       = [aws_appautoscaling_policy.requestcount_policy.arn]
  datapoints_to_alarm = "1"

  dimensions = {
    TargetGroup  = aws_alb_target_group.main.arn_suffix
    LoadBalancer = data.aws_lb.main.arn_suffix
  }

  evaluation_periods = "1"
  metric_name        = "RequestCount"
  namespace          = "AWS/ApplicationELB"
  period             = "60"
  statistic          = "Sum"
  threshold          = var.alarm_request_count
  treat_missing_data = "missing"
}