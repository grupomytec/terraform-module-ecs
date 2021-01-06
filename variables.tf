variable "account_id" {
  description = "Account ID AWS"
  default     = "184730703936"
}

variable "region" {
  description = "Region in AWS"
}

variable "environment" {
  description = "Which environment (dev, staging, production, etc) this group of machines is for"
  default     = "dev"
}

variable "service_name" {
  description = "Name of Service"
}

variable "tags" {
  description = "Custom tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "These templates assume a VPC already exists"
}

variable "subnet_name_filter" {
  description = "Filter subnets within the VPC by using this name"
}

variable "subnet_name_filter_property" {
  description = "Filter subnets within the VPC by using this name"
  default     = "tag:Name"
}

variable "alb_name" {
  description = "Name from existing ALB"
}

variable "host_header" {
  description = "Host Header listener rule"
}

variable "path_pattern" {
  description = "Path Pattern listerner rule"
  default     = ""
}

variable "task_environment" {
  description = "A map of environment variables configured on the primary container"
  type        = map(string)
  default     = {}
}

variable "task_secret" {
  description = "A map of secret environment variables configured on the container"
  type        = map(string)
  default     = {}
}

variable "container_insights" {
  description = "Define if Container Insights is enabled"
  default     = "disabled"
}

variable "image_tag" {
  description = "Tag version from docker image"
  default     = "latest"
}

variable "cpu" {
  description = "Required vCPU units for the service"
  default     = 256
}

variable "memory" {
  description = "Required memory for the service"
  default     = 512
}

variable "min_capacity" {
  description = "Min Capacity in Autoscaling"
  default     = 1
}

variable "max_capacity" {
  description = "Max Capacity in Autoscaling"
  default     = 1
}

variable "metric_type" {
  description = "Metric Type in Autoscaling"
  default     = "ECSServiceAverageCPUUtilization"
}

variable "target_value" {
  description = "Target Value in Autoscaling"
  default     = 60
}

variable "port" {
  description = "A published port for the ECS task"
}

variable "listener_priority" {
  description = "Priority set to Listener Rule"
  default     = null
}

variable "tg_interval" {
  description = "Interval HealthCheck"
  default     = 30
}

variable "tg_path" {
  description = "Path HealthCheck"
  default     = "/"
}

variable "tg_timeout" {
  description = "Timeout HealthCheck"
  default     = 5
}

variable "tg_matcher" {
  description = "Matcher HealthCheck"
  default     = "200"
}

variable "tg_healthy_threshold" {
  description = "Healthy Threshold HealthCheck"
  default     = 5
}

variable "tg_unhealthy_threshold" {
  description = "Unhealthy Threshold HealthCheck"
  default     = 2
}

variable "scale_in_cooldown" {
  default     = 120
}

variable "scale_out_cooldown" {
  default     = 120
}

variable "health_check_grace_period" {
  default     = 300
}

# CloudWatch
variable "alarm_request_count" {
  description = "Value for number of Request is trigger alarm"
  default     = 1000
}

# EFS
variable "efs_id" {
  description = "EFS id for logs"
}

variable "log_directory" {
  description = "Diretory logs to mount in EFS"
}

# Service Discovery
variable "service_discovery_namespace_arn" {
  default     = "ns-p6xz5iqdjdimjsnc"
}