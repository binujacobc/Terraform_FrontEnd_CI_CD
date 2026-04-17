variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

# --------------------------------------------------------------------------
# Hosting infrastructure references (outputs from terraform/)
# --------------------------------------------------------------------------
variable "s3_bucket_name" {
  description = "S3 bucket name for deploying built files"
  type        = string
}

variable "s3_bucket_arn" {
  description = "S3 bucket ARN for IAM policies"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID for cache invalidation"
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for IAM policies"
  type        = string
}

# --------------------------------------------------------------------------
# GitHub source configuration
# --------------------------------------------------------------------------
variable "github_owner" {
  description = "GitHub repository owner (user or org)"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to trigger pipeline on"
  type        = string
  default     = "main"
}
