provider "aws" {
  region = var.region
  allowed_account_ids = [var.aws_account]
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_ACCESS_KEY


assume_role {
    role_arn = "arn:aws:iam::${var.aws_account}:role/svc_terraform"
    session_name = "Terraform"
}

  default_tags {
    tags = {
        created_by = "terraform"
        workspace = terraform.workspace
    }
  }
}