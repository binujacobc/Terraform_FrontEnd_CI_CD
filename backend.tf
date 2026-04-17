terraform {
  backend "s3" {
    bucket         = "binu-uk-terraform-state"
    key            = "frontend-cicd/cicd.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
