import boto3
import os

def lambda_handler(event, context):
    # Read instance IDs from Lambda environment variable
    # INSTANCE_IDS is a comma-separated string set by Terraform: "i-aaa,i-bbb"
    # Same pattern as start_ec2.py — single source of truth via env var
    raw = os.environ['INSTANCE_IDS']
    instance_ids = [i.strip() for i in raw.split(',') if i.strip()]

    if not instance_ids:
        raise ValueError("INSTANCE_IDS environment variable is empty")

    # stop_instances accepts a list — all instances stopped in one API call
    ec2 = boto3.client('ec2')
    response = ec2.stop_instances(InstanceIds=instance_ids)

    for entry in response['StoppingInstances']:
        iid = entry['InstanceId']
        state = entry['CurrentState']['Name']
        print(f"Instance {iid} -> {state}")

    return {
        'statusCode': 200,
        'body': f"Stop triggered for: {instance_ids}"
    }
