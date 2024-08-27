# s3 Remote Backend

This recipe uses `nozaq/remote-state-s3-backend/aws` to create a remote backend for this terraform project.

## Instructions

To set up your remote s3 backend you will take the following steps:

- Create AWS Resources using a Local Backend
- Configure Terraform to use the newly created S3 Remote Backend
- Migrate your state to the Remote backend
- A KMS key for encrypting the S3 bucket

### Prerequisites

You will need the following tools installed on your system:

- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [jq](https://stedolan.github.io/jq/download/) (optional)
- curl

You can also use [TF Terminal](https://github.com/wholestax/tf-terminal) which creates a docker environment that makes it easy to execute your Terraform templates

You will also need an [AWS Account](https://aws.amazon.com/free/) and access keys for an account with sufficient permissions to create the resources needed for the remote backend.

### Step 1) Create Terraform template

Create a new directory with the files from this directory:

```bash
mkdir remote-s3-backend && cd remote-s3-backend

curl -o main.tf https://raw.githubusercontent.com/wholestax/terraform-recipes/main/recipes/remote-s3-backend/main.tf
curl -o local_override.tf https://raw.githubusercontent.com/wholestax/terraform-recipes/main/recipes/remote-s3-backend/local_override.tf
curl -o outputs.tf https://raw.githubusercontent.com/wholestax/terraform-recipes/main/recipes/remote-s3-backend/outputs.tf
```

The `local_override.tf` file, overrides the `main.tf` file to use a local backend. We will migrate the local state to the remote backend aftter the infrastructure is created.

### Step 2) Create AWS User

You need to have an AWS user with sufficeint permissions to create the resources included in the Terraform template. You can use [this policy document](../../modules/remote-state-meta/remote-state-policy.json). Add it through the AWS console or AWS CLI and attach it to the user a use of your choice. Create a new one if needed.

Use the AWS credentials for this user when executing Terraform commands.

### Step 3) Create Remote Backend

Now you can create the infrastructure for the remote backend:

```bash
# Initialize the terraform directory
terraform init

# Create the terraform plan
terraform plan

# If the plan looks good, create the resources
terraform apply
```

That command will create the remote S3 backend and update the local state.

## Configure Remote Backend

Now we have:

- S3 Bucket and Repblica Bucket to store the state
- DynamobDB Table to handle locking
- IAM Resources to give management access to the remote backend

The Local state has also been updated and contains configuration info we need for the next step.

### Add S3 Backend Block

First, configure Terraform to use the new remote backend.

```bash
# We don't need the local backend any more so remove it
rm local_override.tf

```

The `main.tf` file you just created contains the following backend block:

```hcl
  backend s3 {
    bucket         = "BUCKET_NAME_FROM_OUTPUT"
    key            = "REPLACE/WITH/PATH/TO/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "DYNAMODB_TABLE_NAME"
  }
```

You need to edit this block and replace the values with the ones that reflect the resources you just created. These values will be present in the `terraform.tfstate` files that was created by the `terraform apply` command.

If you have `jq` installed, you can retrieve the values you need from the terraform state file with the following command:

```bash
cat terraform.tfstate | jq '{ state_bucket: .outputs.state_bucket.value, kms_key: .outputs.kms_key.value, dynamodb_id: .outputs.dynamodb_table.value.id }'

```

The result will be something like:

```json
{
  "state_bucket": "tf-remote-state30231a2d214ret7453000324002",
  "kms_key": "fake-33231f31-43e9-4330-8ef5-cac1ac15ac07",
  "dynamodb_id": "tf-remote-state-lock"
}
```

If you don't have `jq` installed you will have to find these values in the local state file or your AWS account.

Now you must edit `main.tf` to configure the backend with the appropriate values for the bucket name, DynamoDB table id, and the S3 key you want to use for the state file.

### Create Backend Config file

We will not put the `kms_key` id in the `main.tf` file because it is sensitive information that we do not want to commit to our repo. Therefore we add it to a `backend.config` file.

You can do so with a command like this:

```bash
echo 'kms_key_id="REPLACE_WITH_KMS_KEY_ID"' > backend.config
```

Make sure to add the `backend.config` file to your `.gitignore` file so that it is not committed to your repo.

## Migrate Local State to Remote Backend

Once you make the above edits to your `main.tf` file, it should look something like this:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = "~> 1.6.1"
  backend s3 {
    bucket         = "fake-tf-remote-state30231a2d214ret7453000324002"
    key            = "boostrap/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "fake-tf-remote-state-lock"
  }
}

module "core_remote_backend" {
  source = "./modules/s3-backend"
}
```

Now you can migrate your state from your local backend to your new remote backend. Run the following command from the the root directory

```bash
terraform init -migrate-state --backend-config=./backend.config
```

If you would rather put the KMS key in an environment variable rather than a file, you can also run the command like this:

```bash
terraform init -migrate-state --backend-config="kms_key=${KMS_KEY_ID_SECRET}"
```

You will be asked to confirm that you would like to migrate your local state to the s3 remote state backend.
q

## Conclusion

Now you have Terraform configured to use S3 as a remote backend. You can create multiple backends by supplying different S3 keys in your backend configuration.
