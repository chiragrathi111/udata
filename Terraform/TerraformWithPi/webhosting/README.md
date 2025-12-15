# Static Website Hosting with S3 and CloudFront

This Terraform configuration creates a secure static website hosting solution using AWS S3 and CloudFront.

## Architecture

- **S3 Bucket**: Stores static website files (HTML, CSS, JS)
- **CloudFront**: CDN for global content delivery
- **Origin Access Control (OAC)**: Secures S3 bucket access

## Files Explanation

### `main.tf`
- **aws_s3_bucket**: Creates S3 bucket for website files
- **aws_s3_bucket_public_access_block**: Blocks all public access to S3 bucket
- **aws_cloudfront_origin_access_control**: Creates OAC for secure CloudFront-to-S3 access
- **aws_s3_bucket_policy**: Allows only CloudFront to access S3 objects
- **aws_s3_object**: Uploads all files from `www/` directory to S3
- **aws_cloudfront_distribution**: Creates CDN distribution with HTTPS redirect

### `variable.tf`
- **region**: AWS region (default: ap-south-1)
- **bucket_names**: S3 bucket name (must be globally unique)

### `local.tf`
- **data.aws_caller_identity**: Gets current AWS account ID
- **locals.s3_origin_id**: Creates unique origin ID for CloudFront

### `contain.tf`
- Terraform version and AWS provider configuration

## Usage

1. **Initialize**: `terraform init`
2. **Plan**: `terraform plan`
3. **Apply**: `terraform apply`
4. **Access**: Use CloudFront distribution domain name

## Website Files

Place your website files in the `www/` directory:
- `index.html` - Main page
- `style.css` - Stylesheets
- `script.js` - JavaScript files

## Security Features

- S3 bucket is private (no public access)
- CloudFront uses OAC for secure S3 access
- HTTPS redirect enforced
- Content type detection for proper file serving

## Cleanup

Run `terraform destroy` to remove all resources.