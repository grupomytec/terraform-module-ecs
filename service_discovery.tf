resource "aws_service_discovery_service" "main" {
  name = "${var.service_name}-${var.environment}"

  dns_config {
    namespace_id = var.service_discovery_namespace_arn

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}