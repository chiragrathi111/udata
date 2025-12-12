🔥 Common Condition Types
🔹 By IP Address:

Allow only from office IP

"Condition": {
  "IpAddress": {
    "aws:SourceIp": "203.0.113.0/24"
  }
}

🔹 By Time (Business Hours)
"Condition": {
  "DateGreaterThan": {
    "aws:CurrentTime": "2025-01-01T09:00:00Z"
  }
}

🔹 By Tag

Allow only tagged resources

"Condition": {
  "StringEquals": {
    "aws:ResourceTag/Environment": "prod"
  }
}

🔹 MFA Required
"Condition": {
  "Bool": {
    "aws:MultiFactorAuthPresent": "true"
  }
}

🔹VPC accoding 
"Condition": {
  "StringEquals": {
    "aws:SourceVpc": "vpc-123456"
  }
}

"Condition": {
  "StringLike": {
    "aws:RequestedRegion": "ap-south-1"
  }
}





{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "1",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::mybucket/*",
      "Condition": {
        "StringEquals": {
          "aws:username": "chirag"
        }
      }
    }
  ]
}
