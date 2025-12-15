data "aws_caller_identity" "current" {}

locals {
  s3_origin_id = "S3-${aws_s3_bucket.first_static_web.id}"
}

# how can create key pair in aws using terraform

# run on terminal
#  aws ec2 create-key-pair --key-name MyKeyPair --query 'KeyMaterial' --output text > MyKeyPair.pem 
#  chmod 400 MyKeyPair.pem   /gave to permission to read only owner