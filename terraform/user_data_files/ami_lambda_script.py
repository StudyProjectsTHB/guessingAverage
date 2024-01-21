import json
import os
import boto3
from datetime import datetime, timedelta
import time


def lambda_handler(event, context):
    ec2_client = boto3.client('ec2', )
    image_id = event["ami_id"]
    print(image_id)
    print(context.invoked_function_arn)
    response = ec2_client.describe_images(ImageIds=[image_id])
    image = response['Images'][0]
    status = image['State']

    print(status)

    client_ev = boto3.client('events')
    rule_name = os.environ["event_rule_name"]

    response = client_ev.list_targets_by_rule(
        Rule=rule_name
    )
    for target in response['Targets']:
        try:
            print(target['Input'])
            client_ev.remove_targets(
                Rule=rule_name,
                Ids=[target['Id']]
            )
        except:
            print("no input")

    if status == 'available':
        launch_template_id = os.environ["launch_template_id"]

        response = ec2_client.describe_launch_template_versions(
            LaunchTemplateId=launch_template_id,
            Versions=['$Latest']
        )

        latest_version = response['LaunchTemplateVersions'][0]

        latest_launch_template_data = latest_version['LaunchTemplateData']

        latest_launch_template_data['ImageId'] = image_id

        response = ec2_client.create_launch_template_version(
            LaunchTemplateId=launch_template_id,
            LaunchTemplateData=latest_launch_template_data,
            SourceVersion=str(latest_version['VersionNumber'])
        )

        launch_template_version = response['LaunchTemplateVersion']['VersionNumber']

        print(launch_template_version)
        client_as = boto3.client('autoscaling')
        asg_name = os.environ["asg_name"]
        response = client_as.update_auto_scaling_group(
            AutoScalingGroupName=asg_name,
            LaunchTemplate={
                'LaunchTemplateId': launch_template_id,
                'Version': str(launch_template_version)
            }
        )

        try:
            response = client_as.start_instance_refresh(
                AutoScalingGroupName=asg_name,
                Strategy='Rolling',
                Preferences={
                    'MinHealthyPercentage': 30,
                    'InstanceWarmup': 120,
                    'SkipMatching': False,
                    'ScaleInProtectedInstances': 'Ignore',
                    'StandbyInstances': 'Ignore',
                    # 'MaxHealthyPercentage': 200,  # not available in this boto3 version
                },
            )
        except Exception as e:
            print(e)
            print("asg_update_failed")
            sqs_client = boto3.client('sqs')
            queue_url = os.environ["sqs_asg_queue_url"]
            message = os.environ["fail_message"]
            response = sqs_client.send_message(
                QueueUrl=queue_url,
                MessageBody=message,

            )
            # time.sleep(2)
        print(response)

    elif status == 'pending':
        trigger_time = datetime.now() + timedelta(minutes=2)
        trigger_time_str = trigger_time.strftime('%M %H %d %m ? %Y')
        client_ev.put_rule(
            Name=rule_name,
            ScheduleExpression='cron({})'.format(trigger_time_str)
        )
        data = {"ami_id": image_id}
        client_ev.put_targets(
            Rule=rule_name,
            Targets=[{
                'Id': '1',
                'Arn': context.invoked_function_arn,
                'Input': json.dumps(data)
            }]
        )
