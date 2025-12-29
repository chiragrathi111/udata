import json
import boto3
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

TABLE = os.environ['TABLE']
TOPIC_ARN = os.environ['AWS_SNS_ARN']

def lambda_handler(event, context):
    print("EVENT:", event)

    table = dynamodb.Table(TABLE)

    # Check if event has Records (SQS format)
    if 'Records' not in event:
        print("No Records found in event. Event format:", json.dumps(event, indent=2))
        return {
            "statusCode": 400,
            "body": "Invalid event format - missing Records"
        }

    for record in event['Records']:
        try:
            # Parse the message body
            order = json.loads(record['body'])
            print("Processing order:", order)
            
            # Ensure OrderId exists (DynamoDB primary key requirement)
            if 'OrderId' not in order:
                if 'orderId' in order:
                    order['OrderId'] = order['orderId']  # Convert orderId to OrderId
                else:
                    order['OrderId'] = str(uuid.uuid4())  # Generate unique OrderId
            
            # Add timestamp
            order['Timestamp'] = datetime.utcnow().isoformat()
            
            print("Order with OrderId:", order)
            
            # Store in DynamoDB
            table.put_item(Item=order)
            print("Order saved to DynamoDB")

            # Send SNS notification
            sns.publish(
                TopicArn=TOPIC_ARN,
                Message=f"Order processed: {json.dumps(order)}"
            )
            print("SNS notification sent")
            
        except Exception as e:
            print(f"Error processing record: {str(e)}")
            print(f"Record: {record}")
            raise e

    return {
        "statusCode": 200,
        "body": "Success"
    }