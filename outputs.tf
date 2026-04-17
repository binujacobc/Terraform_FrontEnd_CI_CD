output "codebuild_project_name" {
  description = "CodeBuild project name"
  value       = module.codebuild.project_name
}

output "pipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.this.name
}

output "pipeline_arn" {
  description = "CodePipeline ARN"
  value       = aws_codepipeline.this.arn
}

output "artifact_bucket_name" {
  description = "Artifact S3 bucket name"
  value       = aws_s3_bucket.artifacts.bucket
}

output "codestar_connection_arn" {
  description = "CodeStar connection ARN — MUST be approved in AWS Console"
  value       = aws_codestarconnections_connection.github.arn
}

output "codestar_connection_status" {
  description = "CodeStar connection status (PENDING until approved)"
  value       = aws_codestarconnections_connection.github.connection_status
}

output "manual_step" {
  description = "Action required after apply"
  value       = "Go to AWS Console → Developer Tools → Connections → Approve '${var.project_name}-github' connection"
}
