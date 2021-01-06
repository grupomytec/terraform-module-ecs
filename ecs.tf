# Create Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.service_name}-${var.environment}"

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

  setting {
    name  = "containerInsights"
    value = var.container_insights
  }

  tags = var.tags
}

# Create Service
resource "aws_ecs_service" "main" {
  name              = "${var.service_name}-${var.environment}"
  cluster           = aws_ecs_cluster.main.id
  task_definition   = "${aws_ecs_task_definition.main.family}:${max(aws_ecs_task_definition.main.revision, data.aws_ecs_task_definition.main.revision)}"
  desired_count     = var.min_capacity
  launch_type       = null
  platform_version  = "1.4.0"

  health_check_grace_period_seconds = var.health_check_grace_period

  network_configuration {
    security_groups   = [aws_security_group.main.id]
    subnets           = data.aws_subnet_ids.all_subnets.ids
    assign_public_ip  = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.id
    container_name   = "${var.service_name}-${var.environment}"
    container_port   = var.port
  }

  dynamic "capacity_provider_strategy" {
    for_each = local.capacity_provider_strategy
    
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  service_registries {
    registry_arn = aws_service_discovery_service.main.arn
  }

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_ecs_task_definition.main]

}

# Provides Capacity
locals {
  capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
      weight            = 4
    },
    {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  ]
}

# Autoscaling Target
resource "aws_appautoscaling_target" "main" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Autoscaling Policy
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  name               = "cpu-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  target_tracking_scaling_policy_configuration {
    
    predefined_metric_specification {
      predefined_metric_type = var.metric_type
    }

    target_value = var.target_value

    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_ecs_service.main]
}

# Autoscaling Policy Memory
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  name               = "memory-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  target_tracking_scaling_policy_configuration {
    
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = var.target_value

    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown
  }

  depends_on = [aws_ecs_service.main]
}

resource "aws_appautoscaling_policy" "requestcount_policy" {
  name               = "requestcount-policy"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension
  service_namespace  = aws_appautoscaling_target.main.service_namespace

  step_scaling_policy_configuration {
    cooldown                 = 120
    adjustment_type          = "ChangeInCapacity"
    metric_aggregation_type  = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = var.alarm_request_count
      scaling_adjustment          = 1
    }
  }
}