import json
import boto3
import os
from urllib.parse import unquote_plus

def lambda_handler(event, context):
    """
    Lambda function to process S3 upload events
    This is a simple example that logs the event and copies the file
    """
    
    # Initialize S3 client
    s3_client = boto3.client('s3')
    
    # Get environment variables
    processed_bucket = os.environ.get('PROCESSED_BUCKET')
    log_level = os.environ.get('LOG_LEVEL', 'INFO')
    
    try:
        # Process each record in the event
        for record in event['Records']:
            # Get bucket and object key from the event
            source_bucket = record['s3']['bucket']['name']
            source_key = unquote_plus(record['s3']['object']['key'])
            
            print(f"Processing file: {source_key} from bucket: {source_bucket}")
            
            # Simple processing: copy file to processed bucket with prefix
            destination_key = f"processed/{source_key}"
            
            # Copy the object
            copy_source = {
                'Bucket': source_bucket,
                'Key': source_key
            }
            
            s3_client.copy_object(
                CopySource=copy_source,
                Bucket=processed_bucket,
                Key=destination_key
            )
            
            print(f"Successfully processed {source_key} -> {destination_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Successfully processed files',
                'processed_count': len(event['Records'])
            })
        }
        
    except Exception as e:
        print(f"Error processing files: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e)
            })
        }