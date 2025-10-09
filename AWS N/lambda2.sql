Policy:-
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish"
      ],
      "Resource": "arn:aws:sns:YOUR_REGION:YOUR_ACCOUNT_ID:YOUR_SNS_TOPIC"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:YOUR_REGION:YOUR_ACCOUNT_ID:log-group:EC2StateChanges:*"
    }
  ]
}

====================================================================
import json
import boto3
import time

sns = boto3.client('sns')
logs = boto3.client('logs')

SNS_TOPIC_ARN = 'arn:aws:sns:YOUR_REGION:YOUR_ACCOUNT_ID:YOUR_SNS_TOPIC'

def lambda_handler(event, context):
    try:
        detail = event.get('detail', {})
        instance_id = detail.get('instance-id', 'Unknown')
        state = detail.get('state', 'Unknown')

        message = f"EC2 Instance {instance_id} changed state to {state}."
        print(message)  # This goes to the default Lambda CloudWatch Logs

        # Publish a notification to SNS
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message=message,
            Subject=f"EC2 Instance State Change: {state}"
        )

        # Custom logging to CloudWatch Logs in a custom log group 'EC2StateChanges'
        log_group_name = 'EC2StateChanges'
        log_stream_name = context.aws_request_id

        # Ensure log group exists
        try:
            logs.create_log_group(logGroupName=log_group_name)
        except logs.exceptions.ResourceAlreadyExistsException:
            pass
        
        # Create log stream
        try:
            logs.create_log_stream(logGroupName=log_group_name, logStreamName=log_stream_name)
        except logs.exceptions.ResourceAlreadyExistsException:
            pass

        # Put log event
        logs.put_log_events(
            logGroupName=log_group_name,
            logStreamName=log_stream_name,
            logEvents=[
                {
                    'timestamp': int(time.time() * 1000),
                    'message': message
                }
            ]
        )

    except Exception as e:
        print('Error processing event:', e)
        raise e
