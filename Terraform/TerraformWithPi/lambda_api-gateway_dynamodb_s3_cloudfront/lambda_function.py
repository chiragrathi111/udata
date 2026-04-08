import json, boto3, uuid, os
from datetime import datetime
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super().default(obj)
    
TABLE_NAME = os.environ['STUDENTS_TABLE_NAME']
STUDENT_ID = os.environ['STUDENT_ID_ATTRIBUTE_NAME']

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))
    method = event.get('httpMethod')

    if method == 'POST':
        body = json.loads(event['body'])
        student = {
            STUDENT_ID: str(uuid.uuid4()),
            'name':      body['name'],
            'email':     body['email'],
            'course':    body['course'],
            'marks':     Decimal(str(body.get('marks', 0))),
            'createdAt': datetime.now().isoformat()
        }
        table.put_item(Item=student)
        return resp(201, {'message': 'Created!', 'student': student})

    elif method == 'GET':
        params = event.get('queryStringParameters') or {}
        if STUDENT_ID in params:
            result = table.get_item(Key={STUDENT_ID: params[STUDENT_ID]})
            item = result.get('Item')
            if not item:
                return resp(404, {'message': 'Not found'})
            return resp(200, item)
        result = table.scan()
        return resp(200, result.get('Items', []))

    elif method == 'PUT':
        body = json.loads(event['body'])
        table.update_item(
            Key={STUDENT_ID: body[STUDENT_ID]},
            UpdateExpression='SET #n=:n, email=:e, course=:c, marks=:m',
            ExpressionAttributeNames={'#n': 'name'},
            ExpressionAttributeValues={
                ':n': body['name'], ':e': body['email'],
                ':c': body['course'], ':m': Decimal(str(body['marks']))
            }
        )
        return resp(200, {'message': 'Updated!'})

    elif method == 'DELETE':
        params = event.get('queryStringParameters') or {}
        table.delete_item(Key={STUDENT_ID: params[STUDENT_ID]})
        return resp(200, {'message': 'Deleted!'})

    return resp(400, {'message': 'Invalid method'})

def resp(code, body):
    return {
        'statusCode': code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body, cls=DecimalEncoder)
    }