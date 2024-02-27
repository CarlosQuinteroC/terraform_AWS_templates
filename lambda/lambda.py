import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitorsCounter')

def lambda_handler(event, context):
    response = table.get_item(Key={'id':'count'})
    value = response['Item']['value']
    value = value + 1
    print(value)
    
    response = table.update_item(
        Key={'id':'count'},
        UpdateExpression='SET #v = :val',
        ExpressionAttributeNames={'#v': 'value'},
        ExpressionAttributeValues={':val': value}
    )

    return value