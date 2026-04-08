# ============================================================
# Random suffix for globally unique bucket name
# ============================================================
resource "random_id" "suffix" {
  byte_length = 4
}

# ============================================================
# S3 Bucket - Hosts your frontend (index.html)
# This is like a web server but without managing any server
# ============================================================
resource "aws_s3_bucket" "frontend" {
  bucket = "${lower(var.project_name)}-frontend-${random_id.suffix.hex}"

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
  }
}

# ============================================================
# Block ALL public access to S3 bucket
# Only CloudFront can access it (via OAC) - this is secure
# Users CANNOT access S3 directly, they MUST go through CloudFront
# ============================================================
resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================
# Encryption - all files encrypted at rest
# ============================================================
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ============================================================
# Bucket Policy - ONLY CloudFront can read files from this bucket
# This is the magic: S3 is private, but CloudFront has permission
# ============================================================
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  # Wait for public access block to be applied first
  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            # Only THIS CloudFront distribution can access
            "AWS:SourceArn" = aws_cloudfront_distribution.frontend.arn
          }
        }
      }
    ]
  })
}

# ============================================================
# Upload index.html to S3
# The templatefile() injects your real API Gateway URL into the HTML
# So you don't need to manually paste the URL!
# ============================================================
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  content      = replace(
    file("${path.module}/index.html"),
    "https://YOUR_API_URL/prod/students",
    "${aws_api_gateway_stage.api_stage.invoke_url}/students"
  )
  content_type = "text/html"
  etag         = md5(file("${path.module}/index.html"))
}
