resource "aws_codebuild_project" "this" {
  name         = "${var.project_name}-${var.environment}"
  description  = "Build project for ${var.project_name} (${var.environment})"
  service_role = var.codebuild_role_arn

  build_timeout  = var.build_timeout
  queued_timeout = 30

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = false

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.s3_bucket_name
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      value = var.cloudfront_distribution_id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codebuild/${var.project_name}-${var.environment}"
      stream_name = ""
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
