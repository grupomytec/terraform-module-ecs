data "aws_vpc" "main" {
  id = var.vpc_id
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "main" {
  name        = "${var.service_name}-${var.environment}-sg"
  description = "Allow inbound access from the VPC CIDR"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.port
    to_port         = var.port
    cidr_blocks     = [data.aws_vpc.main.cidr_block]
  }

  ingress {
    protocol        = "tcp"
    from_port       = "22"
    to_port         = "22"
    cidr_blocks     = [data.aws_vpc.main.cidr_block]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}