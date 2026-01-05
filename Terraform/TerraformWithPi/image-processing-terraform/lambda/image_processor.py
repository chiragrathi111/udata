#!/usr/bin/env python3
"""
AWS Lambda Image Processing Function - Simple Version

This function processes uploaded images using basic Python libraries.
For production use, you would want to add PIL/Pillow for better image processing.

Author: Your Name
Project: Image Processing Pipeline
"""

import boto3
import json
import logging
import os
from urllib.parse import unquote_plus

# Configure logging
logger = logging.getLogger()
logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))

# Initialize AWS clients
s3_client = boto3.client('s3')
cloudwatch = boto3.client('cloudwatch')

# Configuration
PROCESSED_BUCKET = os.environ.get('PROCESSED_BUCKET')
SUPPORTED_FORMATS = {'JPEG', 'PNG', 'JPG', 'WEBP', 'GIF'}

def lambda_handler(event, context):
    """
    Main Lambda handler function
    
    Args:
        event: S3 event notification
        context: Lambda context object
    
    Returns:
        dict: Response with status and message
    """
    try:
        # Parse S3 event
        record = event['Records'][0]
        bucket_name = record['s3']['bucket']['name']
        object_key = unquote_plus(record['s3']['object']['key'])
        
        logger.info(f"Processing image: {object_key} from bucket: {bucket_name}")
        
        # Validate file extension
        if not is_supported_image(object_key):
            logger.warning(f"Unsupported file format: {object_key}")
            return create_response(400, "Unsupported file format")
        
        # For now, just copy the original image to different folders
        # In production, you would use PIL/Pillow for actual image processing
        processed_count = copy_image_variations(bucket_name, object_key)
        
        # Send success metrics to CloudWatch
        send_cloudwatch_metric('ImageProcessingSuccess', 1)
        send_cloudwatch_metric('ImagesProcessed', processed_count)
        
        logger.info(f"Successfully processed {processed_count} variations of {object_key}")
        
        return create_response(200, f"Successfully processed {processed_count} image variations")
        
    except Exception as e:
        error_msg = f"Error processing image: {str(e)}"
        logger.error(error_msg)
        
        # Send error metrics to CloudWatch
        send_cloudwatch_metric('ImageProcessingError', 1)
        
        return create_response(500, error_msg)

def is_supported_image(filename):
    """
    Check if the file has a supported image extension
    
    Args:
        filename (str): Name of the file
    
    Returns:
        bool: True if supported, False otherwise
    """
    extension = filename.upper().split('.')[-1]
    return extension in SUPPORTED_FORMATS

def copy_image_variations(source_bucket, object_key):
    """
    Copy the original image to different folders (simulating processing)
    In production, this would use PIL to create actual variations
    
    Args:
        source_bucket (str): Source S3 bucket name
        object_key (str): Original object key
    
    Returns:
        int: Number of variations processed
    """
    variations = ['same', 'small', 'compressed', 'zoom', 'gray']
    processed_count = 0
    
    for variation_name in variations:
        try:
            # Copy original image to new location with variation prefix
            copy_source = {'Bucket': source_bucket, 'Key': object_key}
            new_key = f"{variation_name}/{object_key}"
            
            s3_client.copy_object(
                CopySource=copy_source,
                Bucket=PROCESSED_BUCKET,
                Key=new_key,
                Metadata={
                    'original-key': object_key,
                    'variation': variation_name,
                    'description': get_variation_description(variation_name),
                    'processed-by': 'image-processing-lambda'
                },
                MetadataDirective='REPLACE'
            )
            
            processed_count += 1
            logger.info(f"Created {variation_name} variation: {new_key}")
            
        except Exception as e:
            logger.error(f"Error creating {variation_name} variation: {str(e)}")
    
    return processed_count

def get_variation_description(variation_name):
    """
    Get description for each variation type
    
    Args:
        variation_name (str): Name of the variation
    
    Returns:
        str: Description of the variation
    """
    descriptions = {
        'same': 'Original image (unchanged)',
        'small': 'Small logo size (would be 100x100 with PIL)',
        'compressed': 'Compressed medium size (would be 500x500 with PIL)',
        'zoom': 'Zoomed large size (would be 1000x1000 with PIL)',
        'gray': 'Grayscale version (would be converted with PIL)'
    }
    return descriptions.get(variation_name, 'Processed variation')

def send_cloudwatch_metric(metric_name, value, unit='Count'):
    """
    Send custom metric to CloudWatch
    
    Args:
        metric_name (str): Name of the metric
        value (float): Metric value
        unit (str): Metric unit
    """
    try:
        cloudwatch.put_metric_data(
            Namespace='ImageProcessing',
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': unit
                }
            ]
        )
    except Exception as e:
        logger.error(f"Failed to send CloudWatch metric {metric_name}: {str(e)}")

def create_response(status_code, message):
    """
    Create standardized response
    
    Args:
        status_code (int): HTTP status code
        message (str): Response message
    
    Returns:
        dict: Formatted response
    """
    return {
        'statusCode': status_code,
        'body': json.dumps({
            'message': message,
            'timestamp': getattr(context, 'aws_request_id', 'unknown') if 'context' in globals() else 'unknown'
        })
    }