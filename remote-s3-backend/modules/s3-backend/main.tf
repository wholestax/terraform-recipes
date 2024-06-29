terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

module "remote_state" {
  source  = "nozaq/remote-state-s3-backend/aws"
  version = "1.5.0"

  providers = {
    aws         = aws
    aws.replica = aws.replica
  }

}

resource "aws_iam_user" "terraform" {
  name = "TerraformUser"
  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_user_policy_attachment" "remote_state_access" {
  user       = aws_iam_user.terraform.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}
