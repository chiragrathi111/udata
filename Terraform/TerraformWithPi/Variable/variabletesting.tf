# Using count if your hhave varibale multiple records

variable "s3_bucket_names" {
  type        = list(string)  # list of strings
  description = "List of S3 bucket names for count example"
  default     = ["tf-day08-count-bucket-a-20251016", "tf-day08-count-bucket-b-20251016"]
}

# how can use count with variables for added multiple s3 buckets
resource "aws_s3_bucket" "count_example" {
  count = length(var.s3_bucket_names)  # Set count to the length of the s3_bucket_names list
  bucket = var.s3_bucket_names[count.index] 
  
 # Use the current index to get the bucket name from the list

 tags = {
    Name        = "Count Example Bucket ${count.index + 1}"
    Environment = "Dev"
  }
}

# ========================================================================================================

# Using for_each if your variable have set records

# Set type - used with for_each
variable "s3_bucket_set" {
  type        = set(string)
  description = "Set of S3 bucket names for for_each example"
  default     = ["tf-day08-foreach-bucket-a-20251016", "tf-day08-foreach-bucket-b-20251016"]
}

# how can use for_each with variables for added multiple s3 buckets
resource "aws_s3_bucket" "foreach_example" {
  for_each = var.s3_bucket_set  # Set for_each to the s3_bucket_set
    bucket   = each.value          # Use each.value to get the bucket name from the set 
    tags = {
    Name        = "Foreach Example Bucket ${each.key}"
    Environment = "Dev"
  } 
}

# ========================================================================================================
# Using map variable with for_each
variable "s3_bucket_map" {
  type        = map(string)
  description = "Map of S3 bucket names for for_each example"
  default     = {
    bucket_one = "tf-day08-map-bucket-a-20251016"
    bucket_two = "tf-day08-map-bucket-b-20251016"
  }
}

# how can use for_each with map variable for added multiple s3 buckets
resource "aws_s3_bucket" "map_foreach_example" {
  for_each = var.s3_bucket_map  # Set for_each to the s3_bucket_map
    bucket   = each.value          # Use each.value to get the bucket name from the map 
    tags = {
    Name        = "Map Foreach Example Bucket ${each.key}"
    Environment = "Dev"
  } 
}
# ========================================================================================================
# bucket create depending on after creation of another bucket
resource "aws_s3_bucket" "bucket_a" {
  bucket = "XXXXXXXXXXXXXXXXXXXXXXXXXX"
  tags = {
    Name        = "Bucket A"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "bucket_b" {
  bucket = "YYYYYYYYYYYYYYYYYYYYYYYYYY"
  tags = {
    Name        = "Bucket B"
    Environment = "Dev"
  } 
  depends_on = [aws_s3_bucket.bucket_a]  # Ensure bucket_b is created after bucket_a
}
# ========================================================================================================