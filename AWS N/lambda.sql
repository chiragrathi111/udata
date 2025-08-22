import json
import urllib.parse
import boto3

print('Loading function')

s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    # Get the object, Key and eventName from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    eventname = event['Records'][0]['eventName']
    sns_message = str("This Email Represent a File Status has been Changed in One of Your Bucket \n\n BUCKET NAME: "+ bucket +"\n\n FILE NAME: " + key + "\n\n OPERATION: " + eventname + "\n\n")
    try:
        print(eventname)
        if eventname == "ObjectRemoved:Delete":
            print("File is being Deleted")
            sns_message += str("File Deleted")
        else:
            response = s3.get_object(Bucket=bucket, Key=key)
            sns_message += str("FILE CONTENT TYPE: " + str(response['ContentType']) + "\n\nFILE CONTENT: " + str(response['Body'].read()))
            print("CONTENT TYPE: " + response['ContentType'])
        print(str(sns_message))
        subject= "S3 Bucket[" + bucket + "] Event[" + eventname + "]"
        print(subject)
        sns_response = sns.publish(
        TargetArn='<REPLACE THIS WITH YOUR SNS ARN>',
        Message= str(sns_message),
        Subject= str(subject)
        )
        #return response['ContentType']
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e


===========================================
Policy:-
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:DisassociateKmsKey",
                "logs:DeleteSubscriptionFilter",
                "logs:UntagLogGroup",
                "logs:DeleteLogGroup",
                "logs:DeleteLogStream",
                "logs:PutLogEvents",
                "logs:CreateExportTask",
                "logs:PutMetricFilter",
                "s3:GetObject",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DeleteMetricFilter",
                "logs:TagLogGroup",
                "sns:Publish",
                "logs:DeleteRetentionPolicy",
                "logs:AssociateKmsKey",
                "logs:PutSubscriptionFilter",
                "logs:PutRetentionPolicy"
            ],
            "Resource": "*"
        }
    ]
}
===========================================================   
Custom Log:-
import boto3
import time

s3 = boto3.client('s3')
sns = boto3.client('sns')
logs = boto3.client('logs')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    eventname = event['Records'][0]['eventName']

    sns_message = (f"This Email Represents a File Status change in your bucket\n\n"
                   f"BUCKET NAME: {bucket}\n\nFILE NAME: {key}\n\nOPERATION: {eventname}\n\n")

    try:
        if eventname == "ObjectRemoved:Delete":
            sns_message += "File Deleted"
        else:
            response = s3.get_object(Bucket=bucket, Key=key)
            sns_message += (f"FILE CONTENT TYPE: {response['ContentType']}\n\n"
                            f"FILE CONTENT: {response['Body'].read()}")

        subject = f"S3 Bucket[{bucket}] Event[{eventname}]"

        # Publish to SNS
        sns.publish(
            TargetArn='<REPLACE THIS WITH YOUR SNS ARN>',
            Message=sns_message,
            Subject=subject
        )

        # Custom logging to CloudWatch Logs in 'test' log group
        log_group_name = 'test'
        log_stream_name = context.aws_request_id

        try:
            logs.create_log_group(logGroupName=log_group_name)
        except logs.exceptions.ResourceAlreadyExistsException:
            pass

        try:
            logs.create_log_stream(logGroupName=log_group_name, logStreamName=log_stream_name)
        except logs.exceptions.ResourceAlreadyExistsException:
            pass

        custom_message = f"Bucket={bucket}, Key={key}, Event={eventname}, SNS message sent."

        logs.put_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream_name,
            logEvents=[
                {
                    'timestamp': int(time.time() * 1000),
                    'message': custom_message
                }
            ]
        )

    except Exception as e:
        print(e)
        print(f'Error processing object {key} from bucket {bucket}. Ensure bucket exists in the same region.')
        raise e
