terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = "tf_remote_state_meta"
  path        = "/"
  description = "IAM policy allowing Terraform to manage remote state"
  policy      = file("${path.module}/remote-state-policy.json")
}


