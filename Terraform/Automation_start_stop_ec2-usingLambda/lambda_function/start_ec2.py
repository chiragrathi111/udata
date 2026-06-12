import boto3
import os

def lambda_handler(event, context):
    # INSTANCE_IDS is a comma-separated string like "i-aaa,i-bbb"
    # Lambda env vars can only be strings, so we join the list in Terraform
    # and split it back here to get a proper Python list
    raw = os.environ['INSTANCE_IDS']
    instance_ids = [i.strip() for i in raw.split(',') if i.strip()]

    if not instance_ids:
        raise ValueError("INSTANCE_IDS environment variable is empty")

    # boto3 is the AWS SDK for Python — used to call AWS APIs
    # start_instances natively accepts a list, so passing all IDs at once
    # is more efficient than calling it in a loop
    ec2 = boto3.client('ec2')
    response = ec2.start_instances(InstanceIds=instance_ids)

    for entry in response['StartingInstances']:
        iid = entry['InstanceId']
        state = entry['CurrentState']['Name']
        print(f"Instance {iid} -> {state}")

    return {
        'statusCode': 200,
        'body': f"Start triggered for: {instance_ids}"
    }
