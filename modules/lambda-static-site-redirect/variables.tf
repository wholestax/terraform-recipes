variable "lambda_source_url" {
  description = "The URL of the Lambda source code"
  type        = string
  default     = "https://github.com/wholestax/static-site-redirect-cloudfront/releases/download/v0.0.4/Release.v0.0.4.-.release-0.0.4.zip"
}

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
  default     = "static-site-redirect-at-edge"
}

variable "skip_destroy" {
  description = "Determines whether to delete the function on destroy. Default is false."
  type        = bool
  default     = false
}
