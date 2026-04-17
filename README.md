# Terraform_FrontEnd_CI_CD

Terraform configuration that provisions the AWS CI/CD pipeline (CodePipeline + CodeBuild) for building and deploying the Vue frontend in [sample_web_app_vue](https://github.com/binujacobc/sample_web_app_vue) to the hosting infrastructure defined in [Terraform_FrontEnd_Infra](https://github.com/binujacobc/Terraform_FrontEnd_Infra).

## What this provisions

- **CodeStar Connection** — GitHub source connection (requires one-time manual approval in the AWS Console after `terraform apply`).
- **Artifact S3 bucket** — encrypted, private, with a 30-day lifecycle rule for old artifacts.
- **IAM roles** — separate roles for CodeBuild and CodePipeline with scoped permissions to the hosting S3 bucket and CloudFront distribution.
- **CodeBuild project** — runs the build defined in `buildspec.yml` on the source repo.
- **CodePipeline (V2)** — wires Source (GitHub via CodeStar) → Build (CodeBuild).

## Prerequisites

- Terraform `>= 1.x`
- AWS credentials with permission to create CodePipeline, CodeBuild, IAM, S3, and CodeStar Connections resources.
- The hosting infrastructure from [Terraform_FrontEnd_Infra](https://github.com/binujacobc/Terraform_FrontEnd_Infra) already applied — you need its outputs (S3 bucket name/ARN and CloudFront distribution ID/ARN).
- A `buildspec.yml` in the source repo (Vue app) — the one used here installs dependencies, runs `npm run build`, syncs `dist/` to S3, and invalidates CloudFront.

## Usage

```sh
# 1. Copy and fill in variables
cp terraform.tfvars.example terraform.tfvars

# 2. Initialise (configure backend.tf to match your state backend)
terraform init

# 3. Plan / apply
terraform plan
terraform apply
```

After `apply`, open the AWS Console → Developer Tools → Connections and click **Update pending connection** on the created CodeStar connection to authorise it against your GitHub account/org. The pipeline will remain in a failed state until this is done.

## Inputs (see `variables.tf`)

| Variable | Description |
|---|---|
| `aws_region` | AWS region (default `eu-west-2`). |
| `project_name` | Used as a prefix for all resource names. |
| `environment` | `production` / `staging` / etc. |
| `s3_bucket_name`, `s3_bucket_arn` | Hosting bucket (from the infra repo outputs). |
| `cloudfront_distribution_id`, `cloudfront_distribution_arn` | CloudFront distribution (from the infra repo outputs). |
| `github_owner`, `github_repo`, `github_branch` | GitHub source for the pipeline. |

## Structure

```
.
├── backend.tf                 # Remote state backend (configure to your setup)
├── providers.tf
├── variables.tf
├── outputs.tf
├── main.tf                    # Top-level pipeline + artifact bucket + wiring
├── modules/
│   ├── codebuild/             # CodeBuild project + env
│   └── iam/                   # CodeBuild + CodePipeline roles and policies
└── terraform.tfvars.example
```

## Related repositories

- **Frontend app (source):** https://github.com/binujacobc/sample_web_app_vue
- **Hosting infrastructure:** https://github.com/binujacobc/Terraform_FrontEnd_Infra
