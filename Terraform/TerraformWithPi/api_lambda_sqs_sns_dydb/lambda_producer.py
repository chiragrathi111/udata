import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['QUEUE_URL']

def lambda_handler(event, context):
    print("EVENT:", event)

    body = event.get("body")

    if body:
        order = json.loads(body)
    else:
        order = event   # fallback for testing

    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(event)
    )
    return {
        "statusCode": 200,
        "body": "Message sent to SQS"
    }