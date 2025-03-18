import json
import boto3
import os

def handler(event, context):
    s3 = boto3.client('s3')

    bucket_name = event['detail']['resourcesAffected']['s3Bucket']['name']
    object_key = event['detail']['resourcesAffected']['s3Object']['key']

    quarantine_bucket = os.environ['QUARANTINE_BUCKET']

    # Move file to quarantine bucket
    s3.copy_object(
        Bucket=quarantine_bucket,
        CopySource=f'{bucket_name}/{object_key}',
        Key=object_key
    )

    # Delete the original file
    s3.delete_object(Bucket=bucket_name, Key=object_key)

    return {
        "statusCode": 200,
        "body": json.dumps("File quarantined successfully.")
    }
