Ec2 stop,start and terminate:-

import boto3
import os

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    
    # Read from environment variables
    action = os.environ.get('action')
    instance_id = os.environ.get('instance_id')

    if not action or not instance_id:
        return {
            'statusCode': 400,
            'body': 'Missing "action" or "instance_id" in environment variables.'
        }

    try:
        if action == 'start':
            ec2.start_instances(InstanceIds=[instance_id])
            return {'statusCode': 200, 'body': f'Instance {instance_id} is starting.'}

        elif action == 'stop':
            ec2.stop_instances(InstanceIds=[instance_id])
            return {'statusCode': 200, 'body': f'Instance {instance_id} is stopping.'}

        elif action == 'terminate':
            ec2.terminate_instances(InstanceIds=[instance_id])
            return {'statusCode': 200, 'body': f'Instance {instance_id} is terminating.'}

        else:
            return {'statusCode': 400, 'body': 'Invalid action. Use "start", "stop", or "terminate".'}

    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error: {str(e)}'
        }


 (Added environment variable)       
============================================================================================
Stop and Start Multiple Instance using environment variable:-

import boto3
import os

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    # Get multiple instance_ids from the environment variable
    instance_ids = os.environ.get('INSTANCE_IDS', '').split(',')
    
    if not instance_ids:
        return {
            'statusCode': 400,
            'body': 'No instance_ids found in environment variables.'
        }

    try:
        ec2.stop_instances(InstanceIds=instance_ids)
        return {
            'statusCode': 200,
            'body': f'Stopping instances: {", ".join(instance_ids)}'
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f'Error stopping instances: {str(e)}'
        }

+++++++++++++++++++++++++++++++++++++
INSTANCE_IDS (environment key)
instance1_id,instance2_id (value)
ec2.stop_instances(InstanceIds=instance_ids)  = stop method
ec2.start_instances(InstanceIds=instance_ids) = start method
cron(15 8 * * ? *)

+++++++++++++++++++++++++++++++++++++++
cron(30 3 ? * MON-FRI *)
cron(30 14 ? * MON-FRI *)
=========================================================================================