output "kms_key" {
  description = "The KMS customer master key to encrypt state buckets."
  value       = module.remote_state.kms_key
}

output "state_bucket" {
  description = "The S3 bucket to store the remote state file."
  value       = module.remote_state.state_bucket
}

output "dynamodb_table" {
  description = "The DynamoDB Table used for locking state"
  value       = module.remote_state.dynamodb_table
}
