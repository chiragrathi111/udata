import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
ORDERS_TABLE = os.environ['ORDERS_TABLE']

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        orders_table = dynamodb.Table(ORDERS_TABLE)
        
        # Check for query parameters
        query_params = event.get('queryStringParameters', {}) or {}
        
        if 'customerId' in query_params:
            # Query by customer
            response = orders_table.query(
                IndexName='CustomerIndex',
                KeyConditionExpression='customerId = :cid',
                ExpressionAttributeValues={':cid': query_params['customerId']},
                ScanIndexForward=False,
                Limit=20
            )
        elif 'status' in query_params:
            # Query by status
            response = orders_table.query(
                IndexName='StatusIndex',
                KeyConditionExpression='#status = :status',
                ExpressionAttributeNames={'#status': 'status'},
                ExpressionAttributeValues={':status': query_params['status']},
                ScanIndexForward=False,
                Limit=20
            )
        else:
            # Scan all orders (limited)
            response = orders_table.scan(Limit=20)
        
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'orders': response['Items'],
                'count': len(response['Items'])
            }, cls=DecimalEncoder)
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': 'Internal server error'})
        }
