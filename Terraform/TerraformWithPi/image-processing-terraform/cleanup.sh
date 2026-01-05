#!/bin/bash

# =============================================================================
# AWS Image Processing Pipeline - Cleanup Script
# =============================================================================
# This script safely destroys all resources created by the pipeline
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
NC='\\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e \"${BLUE}[INFO]${NC} $1\"
}

print_success() {
    echo -e \"${GREEN}[SUCCESS]${NC} $1\"
}

print_warning() {
    echo -e \"${YELLOW}[WARNING]${NC} $1\"
}

print_error() {
    echo -e \"${RED}[ERROR]${NC} $1\"
}

# Empty S3 buckets before destruction
empty_s3_buckets() {
    print_status \"Checking for S3 buckets to empty...\"
    
    # Get bucket names from Terraform state
    UPLOAD_BUCKET=$(terraform output -raw upload_bucket_name 2>/dev/null || echo \"\")
    PROCESSED_BUCKET=$(terraform output -raw processed_bucket_name 2>/dev/null || echo \"\")
    
    if [ -n \"$UPLOAD_BUCKET\" ]; then
        print_status \"Emptying upload bucket: $UPLOAD_BUCKET\"
        aws s3 rm \"s3://$UPLOAD_BUCKET\" --recursive || true
        print_success \"Upload bucket emptied\"
    fi
    
    if [ -n \"$PROCESSED_BUCKET\" ]; then
        print_status \"Emptying processed bucket: $PROCESSED_BUCKET\"
        aws s3 rm \"s3://$PROCESSED_BUCKET\" --recursive || true
        print_success \"Processed bucket emptied\"
    fi
}

# Destroy infrastructure
destroy_infrastructure() {
    print_status \"Planning destruction...\"
    terraform plan -destroy
    
    echo
    print_warning \"This will PERMANENTLY DELETE all resources. Are you sure? (type 'yes' to confirm)\"
    read -r response
    
    if [ \"$response\" = \"yes\" ]; then
        print_status \"Destroying infrastructure...\"
        terraform destroy -auto-approve
        print_success \"Infrastructure destroyed successfully!\"
    else
        print_status \"Destruction cancelled.\"
        exit 0
    fi
}

# Clean up local files
cleanup_local_files() {
    print_status \"Cleaning up local files...\"
    
    # Remove Terraform files
    rm -f terraform.tfstate*
    rm -f tfplan
    rm -f lambda.zip
    rm -rf .terraform/
    
    print_success \"Local files cleaned up\"
}

# Main execution
main() {
    echo \"==============================================================================\"
    echo \"AWS Image Processing Pipeline - Cleanup Script\"
    echo \"==============================================================================\"
    echo
    
    print_warning \"This script will destroy ALL resources created by this project!\"
    print_warning \"This action is IRREVERSIBLE!\"
    echo
    
    # Check if Terraform state exists
    if [ ! -f \"terraform.tfstate\" ] && [ ! -f \".terraform/terraform.tfstate\" ]; then
        print_error \"No Terraform state found. Nothing to destroy.\"
        exit 1
    fi
    
    empty_s3_buckets
    destroy_infrastructure
    
    echo
    print_warning \"Do you want to clean up local Terraform files? (y/N)\"
    read -r response
    
    if [[ \"$response\" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        cleanup_local_files
    fi
    
    echo
    print_success \"Cleanup completed successfully!\"
    print_status \"All AWS resources have been destroyed.\"
    echo
}

# Run main function
main \"$@\"