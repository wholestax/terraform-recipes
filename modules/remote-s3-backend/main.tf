terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases : [aws.default, aws.replica]
    }
  }
}


module "remote_state" {
  source  = "nozaq/remote-state-s3-backend/aws"
  version = "1.5.0"

  providers = {
    aws         = aws.default
    aws.replica = aws.replica
  }

}
