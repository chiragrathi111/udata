# 🌐 Static Website Hosting - S3 + CloudFront Complete Guide

## 📋 What is This Project?

This project demonstrates **professional static website hosting** using:
- **S3**: Secure storage for website files
- **CloudFront**: Global CDN for fast content delivery
- **OAC**: Origin Access Control for security
- **HTTPS**: Automatic SSL/TLS encryption

## 🎯 Real-World Scenario: Portfolio Website

### **Problem**: You built a portfolio website and need to host it

**Requirements:**
- ✅ Fast loading worldwide
- ✅ HTTPS (secure)
- ✅ Low cost
- ✅ High availability
- ✅ No server management

### **❌ Bad Solution: EC2 Server**
```
Problems:
- Need to manage server
- Single location (slow for global users)
- Pay for server 24/7 (~$10-30/month)
- Need to configure SSL certificates
- Need to handle security updates
```

### **✅ Good Solution: S3 + CloudFront**
```
Benefits:
- No server management
- Global CDN (fast everywhere)
- Pay only for storage + bandwidth (~$1-5/month)
- Automatic HTTPS
- AWS handles security
- 99.99% availability
```

## 🏗️ Architecture Explained

```
┌─────────────────────────────────────────────────────────────┐
│                    USERS WORLDWIDE                           │
│  🌍 USA    🌏 Asia    🌍 Europe    🌎 Australia            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              CloudFront CDN (Edge Locations)                 │
│  • Caches content globally                                  │
│  • Serves HTTPS automatically                               │
│  • Fast delivery from nearest location                      │
│  • DDoS protection                                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼ (Origin Access Control)
┌─────────────────────────────────────────────────────────────┐
│                   S3 Bucket (Private)                        │
│  • Stores website files (HTML, CSS, JS, images)            │
│  • NOT publicly accessible                                  │
│  • Only CloudFront can access                               │
│  • Versioning enabled                                       │
└─────────────────────────────────────────────────────────────┘
```

## 🔐 Security: Origin Access Control (OAC)

### **Old Way (Insecure):**
```hcl
# ❌ BAD: S3 bucket is public
resource \"aws_s3_bucket_acl\" \"website\" {
  bucket = aws_s3_bucket.website.id
  acl    = \"public-read\"  # Anyone can access!
}
```

**Problems:**
- Anyone can access S3 directly
- Bypass CloudFront (no caching, no HTTPS)
- Security risk
- Higher costs (no CDN caching)

### **New Way (Secure):**
```hcl
# ✅ GOOD: S3 bucket is private
resource \"aws_s3_bucket_public_access_block\" \"website\" {
  bucket = aws_s3_bucket.website.id
  
  block_public_acls       = true  # Block all public access
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Only CloudFront can access via OAC
resource \"aws_cloudfront_origin_access_control\" \"oac\" {
  name                              = \"website-oac\"
  origin_access_control_origin_type = \"s3\"
  signing_behavior                  = \"always\"
  signing_protocol                  = \"sigv4\"
}
```

**Benefits:**
- S3 bucket is completely private
- Only CloudFront can access
- Users MUST go through CloudFront
- Better security and performance

## 📁 File Upload with Content Type Detection

### **The Problem:**
```
Browser downloads index.html instead of displaying it!
Why? Wrong Content-Type header
```

### **The Solution:**
```hcl
resource \"aws_s3_object\" \"files\" {
  for_each = fileset(\"${path.module}/www\", \"**/*\")
  
  bucket = aws_s3_bucket.website.id
  key    = each.value
  source = \"${path.module}/www/${each.value}\"
  
  # 🔑 KEY: Detect content type automatically
  content_type = lookup({
    html = \"text/html\"              # Browser displays HTML
    css  = \"text/css\"               # Browser applies CSS
    js   = \"application/javascript\" # Browser executes JS
    png  = \"image/png\"              # Browser shows image
    jpg  = \"image/jpeg\"
    svg  = \"image/svg+xml\"
  }, split(\".\", each.value)[length(split(\".\", each.value)) - 1], 
     \"application/octet-stream\")  # Default for unknown types
  
  # Update file if content changes
  etag = filemd5(\"${path.module}/www/${each.value}\")
}
```

**How it works:**
1. `fileset()` finds all files in www/ directory
2. `for_each` uploads each file
3. `lookup()` detects file extension
4. Sets correct Content-Type header
5. `etag` triggers update when file changes

## 🚀 CloudFront Configuration

### **Cache Behavior**
```hcl
default_cache_behavior {
  allowed_methods  = [\"GET\", \"HEAD\"]  # Read-only (static site)
  cached_methods   = [\"GET\", \"HEAD\"]  # Cache these methods
  
  # Cache duration
  min_ttl     = 0       # Minimum: 0 seconds
  default_ttl = 3600    # Default: 1 hour
  max_ttl     = 86400   # Maximum: 24 hours
  
  # Force HTTPS
  viewer_protocol_policy = \"redirect-to-https\"
}
```

**What this means:**
- Files cached for 1 hour by default
- HTTP requests redirect to HTTPS
- Users get fast responses from edge locations

### **Price Classes**
```hcl
# Option 1: All edge locations (most expensive)
price_class = \"PriceClass_All\"  # Worldwide

# Option 2: US, Europe, Asia (recommended)
price_class = \"PriceClass_200\"  # Most regions

# Option 3: US, Europe only (cheapest)
price_class = \"PriceClass_100\"  # Limited regions
```

## 🎯 Real-World Use Cases

### **1. Portfolio Website**
```
www/
├── index.html       # Home page
├── about.html       # About page
├── projects.html    # Projects showcase
├── css/
│   └── style.css    # Styles
├── js/
│   └── script.js    # Interactivity
└── images/
    ├── profile.jpg  # Your photo
    └── project1.png # Project screenshots
```

### **2. Documentation Site**
```
www/
├── index.html       # Docs home
├── getting-started.html
├── api-reference.html
├── css/
│   └── docs.css
└── images/
    └── diagrams/
```

### **3. Landing Page**
```
www/
├── index.html       # Single page
├── css/
│   └── landing.css
├── js/
│   └── analytics.js # Google Analytics
└── images/
    └── hero.jpg     # Hero image
```

## 💰 Cost Breakdown

### **Monthly Costs (Example: 10,000 visitors)**

| Service | Usage | Cost |
|---------|-------|------|
| **S3 Storage** | 1GB | $0.023 |
| **S3 Requests** | 10,000 GET | $0.004 |
| **CloudFront** | 10GB transfer | $0.85 |
| **CloudFront Requests** | 10,000 | $0.01 |
| **Total** | | **~$0.89/month** |

**Compare to EC2:**
- t3.micro: $8.50/month
- Elastic IP: $3.60/month
- Total: $12.10/month

**Savings: ~$11/month (92% cheaper!)**

## 🔧 Deployment Steps

### **Step 1: Prepare Your Website**
```bash
# Create www directory
mkdir www

# Add your files
www/
├── index.html
├── style.css
└── script.js
```

### **Step 2: Configure Variables**
```hcl
# terraform.tfvars
region = \"us-east-1\"
bucket_names = \"my-portfolio-website-12345\"  # Must be globally unique
```

### **Step 3: Deploy**
```bash
terraform init
terraform plan
terraform apply

# Get CloudFront URL
terraform output cloudfront_url
```

### **Step 4: Access Your Website**
```
https://d1234567890abc.cloudfront.net
```

## 🔄 Update Website Content

### **Method 1: Terraform (Recommended)**
```bash
# Update files in www/ directory
nano www/index.html

# Apply changes
terraform apply

# Invalidate CloudFront cache (optional)
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths \"/*\"
```

### **Method 2: AWS CLI**
```bash
# Upload single file
aws s3 cp www/index.html s3://your-bucket/index.html

# Upload entire directory
aws s3 sync www/ s3://your-bucket/

# Invalidate cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths \"/index.html\"
```

## 🎓 Advanced Features

### **1. Custom Domain**
```hcl
resource \"aws_cloudfront_distribution\" \"website\" {
  # ... other config ...
  
  aliases = [\"www.example.com\", \"example.com\"]
  
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = \"sni-only\"
  }
}

# Create SSL certificate in us-east-1
resource \"aws_acm_certificate\" \"cert\" {
  provider          = aws.us_east_1
  domain_name       = \"example.com\"
  validation_method = \"DNS\"
  
  subject_alternative_names = [\"www.example.com\"]
}
```

### **2. Error Pages**
```hcl
resource \"aws_cloudfront_distribution\" \"website\" {
  # ... other config ...
  
  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = \"/404.html\"
  }
  
  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = \"/403.html\"
  }
}
```

### **3. Geo-Restriction**
```hcl
restrictions {
  geo_restriction {
    restriction_type = \"whitelist\"
    locations        = [\"US\", \"CA\", \"GB\"]  # Only these countries
  }
}
```

## 🐛 Troubleshooting

### **Issue 1: 403 Forbidden Error**
```bash
# Check S3 bucket policy
aws s3api get-bucket-policy --bucket your-bucket

# Check CloudFront OAC
aws cloudfront get-origin-access-control --id YOUR_OAC_ID

# Solution: Ensure bucket policy allows CloudFront
```

### **Issue 2: Old Content Showing**
```bash
# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths \"/*\"

# Or wait for TTL to expire (default: 1 hour)
```

### **Issue 3: Wrong Content-Type**
```bash
# Check object metadata
aws s3api head-object --bucket your-bucket --key index.html

# Solution: Re-upload with correct content-type
aws s3 cp index.html s3://your-bucket/ \
  --content-type \"text/html\"
```

## 🎯 Interview Questions

**Q: Why use CloudFront instead of S3 website hosting?**
A: CloudFront provides HTTPS, global CDN, better performance, DDoS protection, and more control over caching.

**Q: What is Origin Access Control (OAC)?**
A: OAC allows CloudFront to access private S3 buckets securely, preventing direct public access to S3.

**Q: How does CloudFront caching work?**
A: CloudFront caches content at edge locations based on TTL settings. Users get content from nearest edge location.

**Q: How to update website content?**
A: Upload new files to S3 and invalidate CloudFront cache, or wait for TTL to expire.

## 📚 Best Practices

### ✅ DO
- Use OAC for security
- Enable HTTPS redirect
- Set appropriate cache TTLs
- Use versioning for S3 bucket
- Compress files (gzip)
- Optimize images

### ❌ DON'T
- Make S3 bucket public
- Use long TTLs for frequently changing content
- Forget to invalidate cache after updates
- Store sensitive data in static files
- Use CloudFront for dynamic content

## 🚀 Next Steps

1. **Add Custom Domain**: Use Route 53 + ACM
2. **Enable Logging**: CloudFront access logs
3. **Add WAF**: Web Application Firewall
4. **Implement CI/CD**: Auto-deploy on git push
5. **Add Monitoring**: CloudWatch alarms

---

**Perfect for Resume**: Demonstrates understanding of CDN, static hosting, security best practices, and cost optimization!