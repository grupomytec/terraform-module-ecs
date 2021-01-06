# Create ECR Repository
resource "aws_ecr_repository" "main" {
  name  = "${var.service_name}-${var.environment}"
  tags  = var.tags
}

# Lifecycle policy
resource "aws_ecr_lifecycle_policy" "main" {
  repository  = aws_ecr_repository.main.name

  policy = jsonencode(
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Keep last 10 images",
                "selection": {
                    "tagStatus": "any",
                    "countType": "imageCountMoreThan",
                    "countNumber": 10
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
  )

}