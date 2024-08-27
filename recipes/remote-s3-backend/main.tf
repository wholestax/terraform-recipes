terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

    }
  }
  required_version = "~> 1.9.0"

  backend "s3" {
    bucket         = "fake-tf-remote-state20250827171924666900000002"
    key            = "/fakebootstrap/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "fake-tf-remote-state-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "replica"
  region = "us-west-1"
}

module "remote_state" {
  source = "nozaq/remote-state-s3-backend/aws"
  providers = {
    aws         = aws
    aws.replica = aws.replica
  }
}

module "remote_state_meta" {
  source = "github.com/wholestax/terraform-recipes//modules/remote-state-meta/"

}

resource "aws_iam_user" "terraform" {
  name = "terraform-user"
  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_user_policy_attachment" "remote_state_access" {
  user       = aws_iam_user.terraform.name
  policy_arn = module.remote_state.terraform_iam_policy.arn
}

resource "aws_iam_user_policy_attachment" "remote_state_meta" {
  user       = aws_iam_user.terraform.name
  policy_arn = module.remote_state_meta.policy.arn
}


