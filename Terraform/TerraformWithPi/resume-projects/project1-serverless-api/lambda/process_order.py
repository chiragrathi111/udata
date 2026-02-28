import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')

ORDERS_TABLE = os.environ['ORDERS_TABLE']
INVENTORY_TABLE = os.environ['INVENTORY_TABLE']
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            message = json.loads(record['body'])
            order_id = message['orderId']
            customer_id = message['customerId']
            items = message['items']
            
            print(f"Processing order: {order_id}")
            
            # Check inventory
            orders_table = dynamodb.Table(ORDERS_TABLE)
            inventory_table = dynamodb.Table(INVENTORY_TABLE)
            
            all_available = True
            for item in items:
                product_id = item['productId']
                quantity = item['quantity']
                
                # Get product from inventory
                response = inventory_table.get_item(Key={'productId': product_id})
                
                if 'Item' not in response:
                    all_available = False
                    print(f"Product {product_id} not found")
                    break
                
                product = response['Item']
                stock = int(product.get('stock', 0))
                
                if stock < quantity:
                    all_available = False
                    print(f"Insufficient stock for {product_id}")
                    break
            
            # Update order status
            if all_available:
                # Deduct inventory
                for item in items:
                    inventory_table.update_item(
                        Key={'productId': item['productId']},
                        UpdateExpression='SET stock = stock - :qty',
                        ExpressionAttributeValues={':qty': item['quantity']}
                    )
                
                # Update order status
                orders_table.update_item(
                    Key={'orderId': order_id, 'timestamp': message.get('timestamp', 0)},
                    UpdateExpression='SET #status = :status',
                    ExpressionAttributeNames={'#status': 'status'},
                    ExpressionAttributeValues={':status': 'CONFIRMED'}
                )
                
                status = 'CONFIRMED'
                message_text = f"Order {order_id} confirmed for customer {customer_id}"
            else:
                orders_table.update_item(
                    Key={'orderId': order_id, 'timestamp': message.get('timestamp', 0)},
                    UpdateExpression='SET #status = :status',
                    ExpressionAttributeNames={'#status': 'status'},
                    ExpressionAttributeValues={':status': 'FAILED'}
                )
                
                status = 'FAILED'
                message_text = f"Order {order_id} failed - insufficient inventory"
            
            # Send SNS notification
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Subject=f'Order {status}',
                Message=message_text
            )
            
            print(f"Order {order_id} processed: {status}")
            
        except Exception as e:
            print(f"Error processing order: {str(e)}")
            raise e
    
    return {'statusCode': 200, 'body': 'Orders processed'}
