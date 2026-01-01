import json
import boto3
import os
import logging
from datetime import datetime
from urllib.parse import unquote_plus

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
s3_client = boto3.client('s3')

def lambda_handler(event, context):
    """
    Lambda function triggered by S3 upload events
    
    When an object is uploaded to the upload bucket:
    1. Copy the actual image/file to destination bucket
    2. Create a processing record
    3. Generate logs
    """
    
    # Get environment variables
    destination_bucket = os.environ['DESTINATION_BUCKET']
    
    try:
        # Process each record in the event
        for record in event['Records']:
            # Extract S3 event information
            source_bucket = record['s3']['bucket']['name']
            object_key = unquote_plus(record['s3']['object']['key'])
            object_size = record['s3']['object']['size']
            event_name = record['eventName']
            event_time = record['eventTime']
            
            logger.info(f"Processing S3 event: {event_name}")
            logger.info(f"Source bucket: {source_bucket}")
            logger.info(f"Object key: {object_key}")
            logger.info(f"Object size: {object_size} bytes")
            
            # STEP 1: Copy the actual image/file to destination bucket
            copy_source = {
                'Bucket': source_bucket,
                'Key': object_key
            }
            
            # Copy with same filename (so you can see your image directly)
            destination_key = object_key  # Keep original filename
            
            logger.info(f"Copying actual file to: {destination_key}")
            
            # Copy the actual image/file
            s3_client.copy_object(
                CopySource=copy_source,
                Bucket=destination_bucket,
                Key=destination_key,
                MetadataDirective='COPY'
            )
            
            logger.info(f"✓ Successfully copied actual file: {object_key}")
            
            # STEP 2: Also create a copy in processed folder with timestamp
            timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
            processed_key = f"processed/{timestamp}_{object_key}"
            
            s3_client.copy_object(
                CopySource=copy_source,
                Bucket=destination_bucket,
                Key=processed_key,
                MetadataDirective='COPY'
            )
            
            logger.info(f"✓ Also saved in processed folder: {processed_key}")
            
            # STEP 3: Create processing record
            processing_record = {
                "processing_id": f"{timestamp}-{context.aws_request_id}",
                "source_bucket": source_bucket,
                "source_key": object_key,
                "destination_bucket": destination_bucket,
                "destination_key": destination_key,
                "processed_key": processed_key,
                "object_size": object_size,
                "event_name": event_name,
                "event_time": event_time,
                "processed_time": datetime.utcnow().isoformat(),
                "lambda_function": context.function_name,
                "status": "SUCCESS"
            }
            
            # Save processing record
            record_key = f"records/{timestamp}_{object_key}_record.json"
            
            s3_client.put_object(
                Bucket=destination_bucket,
                Key=record_key,
                Body=json.dumps(processing_record, indent=2),
                ContentType='application/json'
            )
            
            logger.info(f"✓ Created processing record: {record_key}")
            
            # STEP 4: Create simple log
            log_entry = {
                "timestamp": datetime.utcnow().isoformat(),
                "action": "FILE_COPIED",
                "original_file": object_key,
                "copied_to": [destination_key, processed_key],
                "size_bytes": object_size,
                "status": "SUCCESS"
            }
            
            log_key = f"logs/{timestamp}_processing_log.json"
            
            s3_client.put_object(
                Bucket=destination_bucket,
                Key=log_key,
                Body=json.dumps(log_entry, indent=2),
                ContentType='application/json'
            )
            
            logger.info(f"✓ Created log: {log_key}")
            
            # Print summary
            logger.info(f"\n=== PROCESSING COMPLETE ===")
            logger.info(f"Original file: {source_bucket}/{object_key}")
            logger.info(f"Copied to: {destination_bucket}/{destination_key}")
            logger.info(f"Also saved as: {destination_bucket}/{processed_key}")
            logger.info(f"Record created: {destination_bucket}/{record_key}")
            logger.info(f"Log created: {destination_bucket}/{log_key}")
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': f'Successfully processed {len(event["Records"])} files',
                'destination_bucket': destination_bucket,
                'files_copied': len(event["Records"]),
                'timestamp': datetime.utcnow().isoformat()
            })
        }
        
    except Exception as e:
        logger.error(f"❌ Error processing S3 event: {str(e)}")
        
        # Create error record
        try:
            error_record = {
                "error_id": f"{datetime.utcnow().strftime('%Y%m%d%H%M%S')}-{context.aws_request_id}",
                "error_message": str(e),
                "error_time": datetime.utcnow().isoformat(),
                "lambda_function": context.function_name,
                "event_data": event,
                "status": "ERROR"
            }
            
            error_key = f"errors/error_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.json"
            
            s3_client.put_object(
                Bucket=destination_bucket,
                Key=error_key,
                Body=json.dumps(error_record, indent=2),
                ContentType='application/json'
            )
            
            logger.info(f"Created error record: {error_key}")
            
        except Exception as log_error:
            logger.error(f"Failed to create error record: {str(log_error)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'timestamp': datetime.utcnow().isoformat()
            })
        }