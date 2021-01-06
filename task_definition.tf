data "template_file" "task_definition" {
  template = <<EOF
[
  {
    "name": "$${ServiceName}",
    "image": "$${ServiceImage}",
    "essential": true,
    "mountPoints": [
      {
        "containerPath": "$${LogDirectory}",
        "sourceVolume": "efs-logs"
      }
    ],
    "cpu": $${ServiceCPU},
    "memory": $${ServiceMemory}
    $${Ports}$${Logging}$${Environment}$${Secret}
  }
]
EOF
  vars = {
    ServiceName   = "${var.service_name}-${var.environment}"
    ServiceImage  = join(":", [aws_ecr_repository.main.repository_url, var.image_tag])
    ServiceCPU    = var.cpu
    ServiceMemory = var.memory
    LogDirectory  = var.log_directory
    Ports         = ",\n\"portMappings\": [\n\t ${data.template_file.port.rendered} ]"
    Logging       = ",\n\"logConfiguration\": ${data.template_file.logging.rendered}"
    Environment   = length(var.task_environment) > 0 ? ",\n\"environment\": [\n\t ${join(",\n", local.rendered_environment)} ]" : ""
    Secret        = length(var.task_secret) > 0 ? ",\n\"secrets\": [\n\t ${join(",\n", local.rendered_secret)} ]" : ""
  }
}

resource "aws_ecs_task_definition" "main" {
  container_definitions     = data.template_file.task_definition.rendered
  family                    = "${var.service_name}-${var.environment}"
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = var.cpu
  memory                    = var.memory
  execution_role_arn        = aws_iam_role.ecs_tasks_execution_role.arn
  task_role_arn             = aws_iam_role.ecs_tasks_execution_role.arn

  volume {
    name      = "efs-logs"
    efs_volume_configuration {
      file_system_id = var.efs_id
      root_directory = "/${var.environment}/${var.service_name}"
    }
  }
}
