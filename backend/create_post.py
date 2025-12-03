import json
# Force update
import boto3
import uuid
import time
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('TABLE_NAME', 'ContactMessages')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    try:
        # Parse body
        if 'body' not in event:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing request body'})
            }
        
        body = json.loads(event['body'])
        
        # Validate input
        required_fields = ['name', 'message']
        for field in required_fields:
            if field not in body or not body[field]:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': f'Missing required field: {field}'})
                }
        
        # Create item
        item = {
            'id': str(uuid.uuid4()),
            'name': body['name'],
            'email': body.get('email', ''),
            'message': body['message'],
            'timestamp': datetime.utcnow().isoformat(),
            'ttl': int(time.time()) + (30 * 24 * 60 * 60) # 30 days retention
        }
        
        # Write to DynamoDB
        table.put_item(Item=item)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'message': 'Message submitted successfully', 'id': item['id']})
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': 'Internal server error'})
        }
