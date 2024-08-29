terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

    }
  }
  required_version = "~> 1.9.0"
}

locals {
  package_url = var.lambda_source_url
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "terraform_data" "downloaded_package" {
  input = local.downloaded

  triggers_replace = [local.downloaded]

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

module "redirect_lambda_at_edge" {
  source         = "terraform-aws-modules/lambda/aws"
  create_package = false

  lambda_at_edge = true

  function_name = var.function_name
  description   = "Redirects requests for directory paths to the index.html file contained therein"
  handler       = "redirect.handler"
  runtime       = "nodejs20.x"

  local_existing_package = resource.terraform_data.downloaded_package.output

  skip_destroy = var.skip_destroy

  tags = {
    ManagedBy = "terraform"
  }
}
