output "kms_key" {
  description = "The KMS customer master key to encrypt state buckets."
  value       = module.core_remote_backend.kms_key.key_id
}

output "state_bucket" {
  description = "The S3 bucket to store the remote state file."
  value       = module.core_remote_backend.state_bucket.bucket
}

output "dynamodb_table" {
  description = "The DynamoDB Table used for locking state"
  value       = module.core_remote_backend.dynamodb_table
}
