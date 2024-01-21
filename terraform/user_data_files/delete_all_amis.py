import boto3
import json
import os

aws_access_key_id = os.environ["AWS_ACCESS_KEY_ID"]
aws_secret_access_key = os.environ["AWS_SECRET_ACCESS_KEY"]
aws_session_token = os.environ["AWS_SESSION_TOKEN"]
print(aws_access_key_id)
print(aws_secret_access_key)
print(aws_session_token)
session = boto3.Session(
    aws_access_key_id=aws_access_key_id,
    aws_secret_access_key=aws_secret_access_key,
    aws_session_token=aws_session_token,
)

ec2_client = session.client('ec2', region_name='us-east-1')
ami_tags = os.environ["tags"]

tags = json.loads(ami_tags)
response = ec2_client.describe_images(
    Filters=[{
        'Name': 'tag:' + tags[1]['Key'],
        'Values': [tags[1]['Value']]
    }]
)
# print(response)

if not response['Images']:
    print("no images with tag")
else:
    for image in response['Images']:
        print(image['ImageId'])
        ec2_client.deregister_image(ImageId=image['ImageId'])

