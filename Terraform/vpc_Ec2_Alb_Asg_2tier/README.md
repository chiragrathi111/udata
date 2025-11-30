# Terraform 2-Tier Architecture

This Terraform configuration deploys a complete 2-tier architecture on AWS with:
- **Web Tier**: Apache servers (port 80) in public subnets behind external ALB
- **App Tier**: Node.js servers (port 4000) in private subnets behind internal ALB
- **Auto Scaling**: ASG with health checks and automatic instance replacement
- **High Availability**: Multi-AZ deployment across us-east-1a and us-east-1b

Important: do not commit real credentials to Git. There are multiple ways to provide AWS credentials:

1) Recommended — export credentials into your shell (session only):

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="...."
# If these are temporary credentials also export:
export AWS_SESSION_TOKEN="..."
# optionally
export AWS_DEFAULT_REGION="us-east-1"
```

Test your credentials with the AWS CLI:

```bash
# returns account identity if credentials are valid
aws sts get-caller-identity
```

2) AWS named profiles (safer for multiple accounts)
```bash
aws configure --profile myprofile
export AWS_PROFILE=myprofile
terraform plan
```

3) Use a local `terraform.tfvars` file _only_ for non-secret values. Example `terraform.tfvars.example` is provided. Do not check in any secrets.

Quick run (recommended):

```bash
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

If `terraform plan` fails with `InvalidClientTokenId` or `InvalidClientToken`:
- The credentials in use are invalid or expired. Rotate them in IAM and use the new ones.
- If the credentials are temporary (STS), make sure `AWS_SESSION_TOKEN` is set.
- Check for accidental credentials stored in the repo and rotate keys immediately if so.

If you'd like, I can help:
- create a `make` target or small script to load a `.env` file safely (local only),
- or add a provider `profile` var and docs for multi-account workflows.
