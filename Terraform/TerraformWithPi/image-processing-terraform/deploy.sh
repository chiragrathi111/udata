#!/bin/bash

# =============================================================================
# AWS Image Processing Pipeline - Deployment Script
# =============================================================================
# This script automates the deployment of the image processing pipeline
# =============================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    # Check if aws cli is installed
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check if zip is installed
    if ! command -v zip &> /dev/null; then
        print_error "zip is not installed. Please install zip utility first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All prerequisites met!"
}

# Create Lambda deployment package
create_lambda_package() {
    print_status "Creating Lambda deployment package..."
    
    # Remove existing package if it exists
    if [ -f "lambda.zip" ]; then
        rm lambda.zip
        print_status "Removed existing lambda.zip"
    fi
    
    # Create the zip package
    cd lambda
    zip -r ../lambda.zip image_processor.py
    cd ..
    
    print_success "Lambda package created: lambda.zip"
}

# Validate Terraform configuration
validate_terraform() {
    print_status "Validating Terraform configuration..."
    
    # Check if terraform.tfvars exists
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from template..."
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            print_warning "Please edit terraform.tfvars with your email address before continuing."
            print_warning "Run: nano terraform.tfvars"
            exit 1
        fi
    fi
    
    print_success "Configuration files ready!"
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Initializing Terraform..."
    terraform init
    
    print_status "Validating Terraform configuration..."
    terraform validate
    print_success "Terraform configuration is valid!"
    
    print_status "Planning deployment..."
    terraform plan -out=tfplan
    
    echo
    print_warning "Review the plan above. Do you want to proceed with deployment? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Deploying infrastructure..."
        terraform apply tfplan
        rm tfplan
        print_success "Infrastructure deployed successfully!"
        
        # Show outputs
        echo
        print_status "Deployment Summary:"
        terraform output
        
        echo
        print_warning "IMPORTANT: Check your email and confirm SNS subscriptions!"
        print_status "You should receive 2 confirmation emails (Critical and Normal alerts)"
    else
        print_status "Deployment cancelled."
        rm -f tfplan
        exit 0
    fi
}

# Test the deployment
test_deployment() {
    print_status "Testing deployment..."
    
    # Get bucket names from Terraform output
    UPLOAD_BUCKET=$(terraform output -raw upload_bucket_name 2>/dev/null || echo "")
    PROCESSED_BUCKET=$(terraform output -raw processed_bucket_name 2>/dev/null || echo "")
    
    if [ -z "$UPLOAD_BUCKET" ] || [ -z "$PROCESSED_BUCKET" ]; then
        print_error "Could not get bucket names from Terraform output"
        return 1
    fi
    
    print_status "Upload bucket: $UPLOAD_BUCKET"
    print_status "Processed bucket: $PROCESSED_BUCKET"
    
    # Check if test image exists
    if [ -f "test-image.jpg" ] || [ -f "test-image.png" ]; then
        TEST_IMAGE=$(ls test-image.* 2>/dev/null | head -1)
        print_status "Found test image: $TEST_IMAGE"
        
        echo
        print_warning "Do you want to upload the test image? (y/N)"
        read -r response
        
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            print_status "Uploading test image..."
            aws s3 cp "$TEST_IMAGE" "s3://$UPLOAD_BUCKET/"
            
            print_status "Waiting 30 seconds for processing..."
            sleep 30
            
            print_status "Checking processed images..."
            aws s3 ls "s3://$PROCESSED_BUCKET/" --recursive
            
            print_success "Test completed! Check the processed bucket for results."
        fi
    else
        print_warning "No test image found. Create test-image.jpg or test-image.png to test the pipeline."
    fi
}

# Main execution
main() {
    echo "=============================================================================="
    echo "AWS Image Processing Pipeline - Deployment Script"
    echo "=============================================================================="
    echo
    
    check_prerequisites
    create_lambda_package
    validate_terraform
    deploy_infrastructure
    
    echo
    print_warning "Do you want to run a test? (y/N)"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        test_deployment
    fi
    
    echo
    print_success "Deployment completed successfully!"
    print_status "Next steps:"
    echo "  1. Confirm SNS email subscriptions"
    echo "  2. Upload images to test the pipeline"
    echo "  3. Monitor CloudWatch dashboard"
    echo "  4. Check processed images in S3"
    echo
}

# Run main function
main "$@"