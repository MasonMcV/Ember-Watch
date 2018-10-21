import boto3
import urllib
from urllib import request

session = boto3.session.Session(
    region_name='us-east-2',
    aws_access_key_id='AKIAJPUHR4QFCAJAHU5A',
    aws_secret_access_key='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'
)

client = session.client('dynamodb')

dynamodb = session.resource('dynamodb')

table = dynamodb.Table('Ember_Watch')

table.put_item(
    Item={
        'SubmissionID' : 'Z',
        'imgURL' : 'https://proxy.duckduckgo.com/iu/?u=https%3A%2F%2Ftse2.mm.bing.net%2Fth%3Fid%3DOIP.os3Aaxhb7GKKZbI0LeCCkAHaIt%26pid%3D15.1&f=1',
        'long' : 10,
        'lat' : 20
    }
)

submissionID = 'Z'

item = table.get_item(
    Key={
        'SubmissionID' : submissionID
    }
)

URL = item['Item']['imgURL']
img_data = urllib.request.urlopen(URL).read()