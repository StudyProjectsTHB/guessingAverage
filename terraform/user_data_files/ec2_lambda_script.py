import json
import os

import boto3
from datetime import datetime, timedelta
def lambda_handler(event, context):
    instance_id = os.environ["ec2_instance_id"]
    ami_tags = os.environ["ami_tags"]

    print(event['Records'][0]['body'])
    bool_finished = False

    if event['Records'][0]['body'] == instance_id and not bool_finished:
        bool_finished = True
        ec2_client = boto3.client('ec2')
        image_name = f'image_{datetime.now().strftime("%Y-%m-%d_%H-%M-%S")}'
        try:
            ec2_reponse = ec2_client.create_image(
                InstanceId=instance_id,
                Name=image_name,
            )
            image_id = ec2_reponse['ImageId']
            tag_response = ec2_client.create_tags(
                Resources=[image_id],
                Tags=json.loads(ami_tags)
            )
        except Exception as e:
            print(e)
            tags = json.loads(ami_tags)
            response = ec2_client.describe_images(
                Filters=[{
                    'Name': 'tag:' + tags[1]['Key'],
                    'Values': [tags[1]['Value']]

                }]
            )
            if not response['Images']:
                print("no images with tag")
            else:
                print('delete old image')
                newst_ami = max(response['Images'], key=lambda x: datetime.strptime(x['CreationDate'], "%Y-%m-%dT%H:%M:%S.%fZ"))
                ami_id = newst_ami['ImageId']
                ec2_client.deregister_image(ImageId=ami_id)

                print('create new image')
                ec2_response = ec2_client.create_image(
                    InstanceId=instance_id,
                    Name=image_name,
                )
                image_id = ec2_response['ImageId']
                tag_response = ec2_client.create_tags(
                    Resources=[image_id],
                    Tags=json.loads(ami_tags)
                )
    else:
        print(event['Records'][0]['body'])

    if bool_finished:
        client_ev = boto3.client('events')

        trigger_time = datetime.now() + timedelta(minutes=2)
        trigger_time_str = trigger_time.strftime('%M %H %d %m ? %Y')

        rule_name = os.environ["event_rule_name"]
        print('cron({})'.format(trigger_time_str))
        client_ev.put_rule(
            Name=rule_name,
            ScheduleExpression='cron({})'.format(trigger_time_str)
        )
        data = {"ami_id": image_id}
        client_ev.put_targets(
            Rule=rule_name,
            Targets=[{
                'Id': '1',
                'Arn': os.environ["ami_lambda_arn"],
                'Input': json.dumps(data)
            }]

        )