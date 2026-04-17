# --------------------------------------------------------------------------
# CodeStar Connection — GitHub (requires manual approval in AWS Console)
# --------------------------------------------------------------------------
resource "aws_codestarconnections_connection" "github" {
  name          = "${var.project_name}-github"
  provider_type = "GitHub"

  tags = {
    Name = "${var.project_name}-github"
  }
}

# --------------------------------------------------------------------------
# Artifact Bucket — created here to break circular dependency with IAM
# --------------------------------------------------------------------------
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-${var.environment}-artifacts"
  force_destroy = true

  tags = {
    Name = "${var.project_name}-${var.environment}-artifacts"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    id     = "cleanup-old-artifacts"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

# --------------------------------------------------------------------------
# IAM — Roles for CodeBuild and CodePipeline
# --------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  project_name               = var.project_name
  environment                = var.environment
  s3_bucket_arn              = var.s3_bucket_arn
  cloudfront_distribution_arn = var.cloudfront_distribution_arn
  artifact_bucket_arn        = aws_s3_bucket.artifacts.arn
}

# --------------------------------------------------------------------------
# CodeBuild — Build project
# --------------------------------------------------------------------------
module "codebuild" {
  source = "./modules/codebuild"

  project_name               = var.project_name
  environment                = var.environment
  codebuild_role_arn         = module.iam.codebuild_role_arn
  s3_bucket_name             = var.s3_bucket_name
  cloudfront_distribution_id = var.cloudfront_distribution_id
}

# --------------------------------------------------------------------------
# CodePipeline — Source + Build pipeline
# --------------------------------------------------------------------------
resource "aws_codepipeline" "this" {
  name          = "${var.project_name}-${var.environment}"
  role_arn      = module.iam.codepipeline_role_arn
  pipeline_type = "V2"

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_output"]

      configuration = {
        ProjectName = module.codebuild.project_name
      }
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}"
  }
}
