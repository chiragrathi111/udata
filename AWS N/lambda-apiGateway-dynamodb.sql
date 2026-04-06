Lambda-ApiGateway-Dynamodb
---------------------------

PART 1 — Create DynamoDB Table

Step 1 — Go to DynamoDB

AWS Console → DynamoDB → Create table

Table name:        Students
Partition key:     studentId     (type: String)
Sort key:          (leave empty)
Table settings:    On-demand     (no capacity planning needed)
-----------------------------------------------------------------------------
PART 2 — Create Lambda Function

Step 2 — Create Lambda

AWS Console → Lambda → Create function
→ Author from scratch
→ Function name: student-management
→ Runtime: Python 3.12
→ Create function

-----------------------------------------------------------------------------
Step 3 — Give Lambda permission to access DynamoDB

Lambda → Configuration → Permissions
→ Click the Role name (opens IAM)
→ Add permissions → Attach policies
→ Search "DynamoDB" → select AmazonDynamoDBFullAccess
→ Add permissions

------------------------------------------------------------------------------
Step 4 — Write Lambda Code

import json
import boto3
import uuid
from datetime import datetime
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super().default(obj)

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Students')

def lambda_handler(event, context):
    print("EVENT:", json.dumps(event))  # ← helps debug
    
    method = event.get('httpMethod')

    if method == 'POST':
        body = json.loads(event['body'])
        student = {
            'studentId': str(uuid.uuid4()),
            'name':      body['name'],
            'email':     body['email'],
            'course':    body['course'],
            'marks':     Decimal(str(body.get('marks', 0))),
            'createdAt': datetime.now().isoformat()
        }
        table.put_item(Item=student)
        return build_response(201, {'message': 'Student created!', 'student': student})

    elif method == 'GET':
        params = event.get('queryStringParameters') or {}
        if 'studentId' in params:
            result = table.get_item(Key={'studentId': params['studentId']})
            student = result.get('Item')
            if not student:
                return build_response(404, {'message': 'Student not found'})
            return build_response(200, student)
        else:
            result = table.scan()
            return build_response(200, result.get('Items', []))

    elif method == 'PUT':
        body = json.loads(event['body'])
        table.update_item(
            Key={'studentId': body['studentId']},
            UpdateExpression='SET #n = :n, email = :e, course = :c, marks = :m',
            ExpressionAttributeNames={'#n': 'name'},
            ExpressionAttributeValues={
                ':n': body['name'],
                ':e': body['email'],
                ':c': body['course'],
                ':m': Decimal(str(body['marks']))
            }
        )
        return build_response(200, {'message': 'Student updated!'})

    elif method == 'DELETE':
        params = event.get('queryStringParameters') or {}
        table.delete_item(Key={'studentId': params['studentId']})
        return build_response(200, {'message': 'Student deleted!'})

    return build_response(400, {'message': 'Invalid request'})


def build_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body, cls=DecimalEncoder)
    }
***************************************************************
Dynamic Data:-

import json
import boto3
import uuid
import os
from datetime import datetime
from decimal import Decimal

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super().default(obj)

# ✅ Read from environment variables
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
        return build_response(201, {'message': 'Student created!', 'student': student})

    elif method == 'GET':
        params = event.get('queryStringParameters') or {}
        if STUDENT_ID in params:
            result = table.get_item(Key={STUDENT_ID: params[STUDENT_ID]})
            student = result.get('Item')
            if not student:
                return build_response(404, {'message': 'Student not found'})
            return build_response(200, student)
        else:
            result = table.scan()
            return build_response(200, result.get('Items', []))

    elif method == 'PUT':
        body = json.loads(event['body'])
        table.update_item(
            Key={STUDENT_ID: body[STUDENT_ID]},
            UpdateExpression='SET #n = :n, email = :e, course = :c, marks = :m',
            ExpressionAttributeNames={'#n': 'name'},
            ExpressionAttributeValues={
                ':n': body['name'],
                ':e': body['email'],
                ':c': body['course'],
                ':m': Decimal(str(body['marks']))
            }`
        )
        return build_response(200, {'message': 'Student updated!'})

    elif method == 'DELETE':
        params = event.get('queryStringParameters') or {}
        table.delete_item(Key={STUDENT_ID: params[STUDENT_ID]})
        return build_response(200, {'message': 'Student deleted!'})

    return build_response(400, {'message': 'Invalid request'})


def build_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(body, cls=DecimalEncoder)
    }			

-----------------------------------------------------------------------------
PART 3 — Create API Gateway

Step 5 — Create REST API

AWS Console → API Gateway → Create API
→ REST API → Build
→ API name: student-api
→ Endpoint type: Regional
→ Create API

------------------------------------------------------------------------------
Step 6 — Create Resource

API Gateway → student-api → Resources
→ Create Resource
→ Resource name: students
→ Resource path: /students
→ Create Resource

-------------------------------------------------------------------------------
Step 7 — Create 4 Methods on /students

For each method (GET, POST, PUT, DELETE):

Resources → /students → Create Method
→ Select GET (repeat for POST, PUT, DELETE)
→ Check ✅ "Lambda proxy integration"
→ Integration type: Lambda Function
→ Lambda function: student-management
→ Save → OK (grant permission popup)


NOTE:-

Why this matters
Without Proxy								With Proxy
API Gateway sends only body				API Gateway sends full event
event['httpMethod'] → KeyError ❌		event['httpMethod'] → works ✅
No headers, no query params				Headers, query params, method all included

--------------------------------------------------------------------------------
Step 8 — Deploy API

API Gateway → Deploy API
→ Stage: New stage
→ Stage name: prod
→ Deploy

Copy the Invoke URL — looks like:

https://abc123xyz.execute-api.ap-southeast-2.amazonaws.com/prod
----------------------------------------------------------------------------------
Postman curl:-

CREATE — Add new student

curl -X POST https://your-api-url/prod/students \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Chirag Patel",
    "email": "chirag@example.com",
    "course": "Computer Science",
    "marks": 85
  }'
-----------------------------------------------------------------------------------
READ — Get all students

curl https://your-api-url/prod/students

-----------------------------------------------------------------------------------
READ — Get single student

curl "https://your-api-url/prod/students?studentId=550e8400-e29b-41d4-a716"

-----------------------------------------------------------------------------------
UPDATE — Update student marks

curl -X PUT https://your-api-url/prod/students \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": "550e8400-e29b-41d4-a716",
    "name": "Chirag Patel",
    "email": "chirag@example.com",
    "course": "Computer Science",
    "marks": 95
  }'

-----------------------------------------------------------------------------------
DELETE — Remove student

curl -X DELETE "https://your-api-url/prod/students?studentId=550e8400-e29b-41d4-a716" 

-----------------------------------------------------------------------------------
