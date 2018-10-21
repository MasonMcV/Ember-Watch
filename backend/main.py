import boto3
import urllib
from urllib import request
import label_image
import logFirebase
import filter

def RollTide(submissionID):
    session = boto3.session.Session(
        region_name='us-east-2',
        aws_access_key_id='AKIAJPUHR4QFCAJAHU5A',
        aws_secret_access_key='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'
    )

    client = session.client('dynamodb')

    dynamodb = session.resource('dynamodb')

    table = dynamodb.Table('Ember_Watch')

    item = table.get_item(
        Key={
            'SubmissionID' : submissionID
        }
    )

    URL = item['Item']['imgURL']
    lon = float(item['Item']['long'])
    lat = float(item['Item']['lat'])
    img_data = urllib.request.urlopen(URL).read()
    if(label_image.main(img_data) & filter.filterData(lon, lat)):
        logFirebase.logToFirebase(item['Item'])

    table.delete_item(
        Key={
            'SubmissionID' : submissionID
        }
    )