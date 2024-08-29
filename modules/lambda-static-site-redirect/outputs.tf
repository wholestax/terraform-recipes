output "lambda_function_arn" {
  description = "The ARN identifying your Lambda function"
  value       = module.redirect_lambda_at_edge.lambda_function_arn
}

output "lambda_function_qualified_arn" {
  description = "The ARN identifying your Lambda function version to be used with Cloudfront"
  value       = module.redirect_lambda_at_edge.lambda_function_qualified_arn
}

