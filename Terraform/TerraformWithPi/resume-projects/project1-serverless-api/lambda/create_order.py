import json
import boto3
import os
import uuid
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

ORDERS_TABLE = os.environ['ORDERS_TABLE']
INVENTORY_TABLE = os.environ['INVENTORY_TABLE']
ORDER_QUEUE_URL = os.environ['ORDER_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        
        # Validate required fields
        required_fields = ['customerId', 'items', 'totalAmount']
        for field in required_fields:
            if field not in body:
                return {
                    'statusCode': 400,
                    'headers': {'Content-Type': 'application/json'},
                    'body': json.dumps({'error': f'Missing required field: {field}'})
                }
        
        # Generate order ID
        order_id = str(uuid.uuid4())
        timestamp = int(datetime.utcnow().timestamp())
        
        # Create order object
        order = {
            'orderId': order_id,
            'customerId': body['customerId'],
            'items': body['items'],
            'totalAmount': Decimal(str(body['totalAmount'])),
            'status': 'PENDING',
            'timestamp': timestamp,
            'createdAt': datetime.utcnow().isoformat(),
            'expirationTime': timestamp + (30 * 24 * 60 * 60)  # 30 days TTL
        }
        
        # Save to DynamoDB
        orders_table = dynamodb.Table(ORDERS_TABLE)
        orders_table.put_item(Item=order)
        
        # Send to SQS for async processing
        sqs.send_message(
            QueueUrl=ORDER_QUEUE_URL,
            MessageBody=json.dumps({
                'orderId': order_id,
                'customerId': body['customerId'],
                'items': body['items']
            })
        )
        
        return {
            'statusCode': 201,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': 'Order created successfully',
                'orderId': order_id,
                'status': 'PENDING'
            })
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Internal server error'})
        }
