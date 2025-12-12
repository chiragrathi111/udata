# Explined Terraform Lifecycle Meta-Argument:-

# ignore_changes :- ignore_changes allows you to ignore changes to a particular attribute. 
# The ignore_changes meta-argument is a list of attributes that Terraform will ignore changes to. 
# This is useful when you want to ignore changes to a particular attribute, such as a password or a secret key.

# create_before_destroy :- create_before_destroy allows you to create a new resource before destroying the old one. 
# This is useful when you want to ensure that a new resource is created before the old one

# prevent_destroy :- prevent_destroy allows you to prevent a resource from being destroyed. 
# This is useful when you want to ensure that a resource is not accidentally destroyed.

# replace_triggered_by :- replace_triggered_by allows you to specify a list of resources that will trigger a replacement of the resource when they change. 
# This is useful when you want to ensure that a resource is replaced when another resource changes.

# pre and post condition :- pre and post conditions allow you to specify conditions that must be met before or after a resource is created or destroyed. 
# This is useful when you want to ensure that certain conditions are met before or after a resource

# ========================================================================================================

resource "aws_s3_bucket" "name" {
  bucket = "tf-day08-lifecycle-bucket-20251016"
  acl    = "private"
  versioning {
    enabled = true
  }

lifecycle {
  create_before_destroy = true  // Create new bucket before destroying the old one
#   if false means it will destory first ten created new bucket
}
}

# ------------------------------------------------------------------------------------------------
resource "aws_s3_bucket_object" "name" {
  bucket = aws_s3_bucket.name.bucket
  key    = "test.txt"
  source = "test.txt"
  lifecycle {
    ignore_changes = [
      key,source
    #   This ignore_changges will use for if want any key value not changes,just for example if instance count = 1
    # and this count key inside on ignore_changes then it will not change the count value
    ]
  }
}

# ========================================================================================================
#  prevent_destroy example
resource "aws_s3_bucket" "prevent_destroy_example" {
  bucket = "tf-day08-prevent-destroy-bucket-20251016"
  acl    = "private"
    versioning {
        enabled = true
    }
    lifecycle {
        prevent_destroy = true
    # This will prevent the bucket from being destroyed
    # Means this is true then it will not destroy the bucket
    }
}

# ========================================================================================================

# replace_triggered_by example
resource "aws_s3_bucket" "replace_triggered_by_example" {
  bucket = "tf-day08-replace-triggered-by-bucket-20251016"
  acl    = "private"
    versioning {
        enabled = true
    }
    lifecycle {
        replace_triggered_by = [aws_s3_bucket.name]
    # This will replace the bucket when the aws_s3_bucket.name resource changes
    }
}

# ========================================================================================================

#  Pre and Post condition example
resource "aws_s3_bucket" "pre_post_condition_example" {
  bucket = "tf-day08-pre-post-condition-bucket-20251016"
  acl    = "private"
    versioning {
        enabled = true
    }
    lifecycle {
        precondition {
            condition     = length(aws_s3_bucket.name.bucket) > 0
            error_message = "The bucket name must not be empty."
            # This will check the bucket name is not empty before creating the bucket
        }
        postcondition {
            condition     = aws_s3_bucket.name.versioning[0].enabled == true
            error_message = "The bucket versioning must be enabled."
            # This will check the bucket versioning is enabled after creating the bucket
        }
    }
}

 