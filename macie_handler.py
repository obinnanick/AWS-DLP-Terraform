import json
import boto3

def lambda_handler(event, context):
    sns_client = boto3.client('sns')

    # Extract Macie finding details
    finding_details = json.dumps(event, indent=4)

    # Publish the finding to SNS topic
    response = sns_client.publish(
        TopicArn='arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:macie-alert-topic',
        Message=finding_details,
        Subject='AWS Macie Finding Alert'
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Macie alert sent successfully!')
    }
