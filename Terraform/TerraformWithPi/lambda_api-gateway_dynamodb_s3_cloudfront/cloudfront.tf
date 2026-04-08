# ============================================================
# CloudFront Origin Access Control (OAC)
# 
# Think of OAC as a "VIP pass" that only CloudFront has.
# S3 bucket is locked (private), but CloudFront shows this pass
# and S3 says "OK, you can read my files".
# Without OAC, either S3 is public (bad!) or CloudFront can't read it.
# ============================================================
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for S3 frontend bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"    # Always sign requests to S3
  signing_protocol                  = "sigv4"     # Use AWS Signature V4
}

# ============================================================
# CloudFront Distribution
#
# CloudFront = CDN (Content Delivery Network)
# It caches your index.html at 400+ edge locations worldwide
# User in India → gets file from Mumbai edge (fast!)
# User in USA → gets file from Virginia edge (fast!)
# Without CloudFront → everyone hits S3 in one region (slow for far users)
#
# Flow: User → CloudFront Edge → S3 Bucket (only on cache miss)
# ============================================================
resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"   # When user visits /, serve index.html
  comment             = "${var.project_name} Student Portal Frontend"

  # ---- Where CloudFront gets files from (S3 bucket) ----
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  # ---- How CloudFront handles requests ----
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]           # Frontend only needs GET
    cached_methods         = ["GET", "HEAD"]           # Cache GET responses
    target_origin_id       = "S3-${aws_s3_bucket.frontend.id}"
    viewer_protocol_policy = "redirect-to-https"       # Force HTTPS

    forwarded_values {
      query_string = false    # Don't forward query strings to S3
      cookies {
        forward = "none"      # Don't forward cookies to S3
      }
    }

    min_ttl     = 0        # Minimum cache time (seconds)
    default_ttl = 300      # Default cache: 5 minutes
    max_ttl     = 3600     # Maximum cache: 1 hour
  }

  # ---- Access restrictions (none - public website) ----
  restrictions {
    geo_restriction {
      restriction_type = "none"   # Allow access from all countries
    }
  }

  # ---- SSL Certificate (free default CloudFront cert) ----
  viewer_certificate {
    cloudfront_default_certificate = true   # Free HTTPS with *.cloudfront.net domain
    # For custom domain (e.g., portal.example.com), use ACM certificate instead
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
