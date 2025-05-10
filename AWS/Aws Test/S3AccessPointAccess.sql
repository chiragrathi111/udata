==============================================================================
S3 Bucket permisstion:-

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "*",
      "Resource": [
        "bucket_ARN",
        "bucket_ARN/*"
      ],
      "Condition": {
        "StringEquals": {
          "s3:DataAccessPointAccount": "AWs accountId12 digit"
        }
      }
    }
  ]
}









==================================================================================================
S3 Access point permission:-

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Principal": {
        "AWS": "user_ARN"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": ""
    }
  ]
}
