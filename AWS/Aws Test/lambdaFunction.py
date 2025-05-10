import boto3
s3_client = boto3.client("s3")
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("dynamodb1") ##enter Dynamo DB table name
def lambda_handler(event, context):

     for record in event['Records']:   
        bucket_name = record['s3']['bucket']['name']
        s3_file_name = record['s3']['object']['key']
        resp = s3_client.get_object(Bucket=bucket_name,Key=s3_file_name)
        data = resp['Body'].read().decode("utf-8")
        Students = data.split("\n")
        for stud in Students:
                print(stud)
                stud_data = stud.split(",")
                try:
                        table.put_item(
                                Item = {
                                        "Unique"    : stud_data[0],   ##enter Dynamo DB Parition key
                                        "Name"      : stud_data[1],
                                        "Subject"   : stud_data[2]
                                        }
                                )
                except Exception as e:
                       print("End of file")
-----------------------------------------------------------------------------------------                       

import boto3
from uuid import uuid4
s3 = boto3.client("s3")
dynamodb = boto3.resource('dynamodb')
dynamoTable = dynamodb.Table('dynamodb1')
def lambda_handler(event, context):   

     for record in event['Records']:   
        bucket_name = record['s3']['bucket']['name']
        s3_file_name = record['s3']['object']['key']
        size = record['s3']['object'].get('size',-1)
        event_name = record['eventName']
        event_name = record['eventTime']
        try:
                dynamoTable.put_item(
                        Item = {
                                "Unique"    : str(uuid4()),
                                "Bucket"    : bucket_name,
                                "Object"    : object_key,
                                "Size"      : size
                        }
                        )
        except Exception as e:
                print("End of file")        
=========================================================================
