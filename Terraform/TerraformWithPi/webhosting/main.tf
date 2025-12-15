resource "aws_s3_bucket" "first_static_web" {
  bucket = var.bucket_names
  region = var.region
}

resource "aws_s3_bucket_public_access_block" "first_static_web_block" {
    bucket = aws_s3_bucket.first_static_web.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  
}

resource "aws_cloudfront_origin_access_control" "aws_cloudfront_origin_access_control" {
  name                              = "cf-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
  
}

resource "aws_s3_bucket_policy" "aws_s3_bucket_policy" {
  bucket = aws_s3_bucket.first_static_web.id
  depends_on = [ aws_s3_bucket_public_access_block.first_static_web_block ] //this bucket policy depend on public access block

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Sid": "AllowCloudFrontServicePrincipalReadOnly",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "cloudfront.amazonaws.com"
        },
        "Action" = "s3:GetObject",
        "Resource" = "${aws_s3_bucket.first_static_web.arn}/*"
        "Condition" = {
          "StringEquals" = {
            "aws:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
      }
    ]
  })
# Online JSON Policy Generator reference
#   policy = jsonencode({
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "Statement1",
#       "Effect": "Allow",
#       "Principal": {
#         "AWS": "cloudfront.amazonaws.com"
#       },
#       "Action": [
#         "s3:GetObject"
#       ],
#       "Resource": "*"
#     }
#   ]
# })
  
}

// aws_s3_object is workin because aws_s3_bucket_object is deprecated
resource "aws_s3_object" "object" {
    for_each = fileset("${path.module}/www", "**/*")
    bucket = aws_s3_bucket.first_static_web.id
        key    = each.value
    source = "${path.module}/www/${each.value}"
    # acl    = "public-read"
    etag = filemd5("${path.module}/www/${each.value}")
#    this is for testing purpose only and i understand the risk of public read
    content_type = lookup({
        html = "text/html"
        css  = "text/css"
        js   = "application/javascript"
        png  = "image/png"
        jpg  = "image/jpeg"
        jpeg = "image/jpeg"
        gif  = "image/gif"
        svg  = "image/svg+xml"
    }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.first_static_web.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    origin_access_control_id = aws_cloudfront_origin_access_control.aws_cloudfront_origin_access_control.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "S3 static website distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {  // Query strings are not forwarded to the origin by default, since it's not a good practice for static websites
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"  // Redirect HTTP to HTTPS
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

#   price_class = "PriceClass_100" // Use only US, Canada and Europe edge locations

  restrictions {
    geo_restriction {
      restriction_type = "none"
    #   This place have two options: whitelist or blacklist
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
  
}