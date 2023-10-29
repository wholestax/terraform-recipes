# s3 Remote Backend

This module uses `nozaq/remote-state-s3-backend/aws` to create a remote backend for this terraform project.

It takes no inputs.

It outputs only the `state_bucket`, `dynamodb_table` and `kms_key` which are required for using the remote backend.

Other outputs provided by `nozaq/remote-state-s3-backend/aws` are not output by this module.
