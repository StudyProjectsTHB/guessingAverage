import os
import boto3


def lambda_handler(event, context):
    client_sqs = boto3.client('sqs')
    asg_name = os.environ["asg_name"]
    queue_url = os.environ["sqs_asg_queue_url"]

    response = client_sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=10,
        VisibilityTimeout=0,
        WaitTimeSeconds=2
    )
    print(response)

    if 'Messages' in response:
        for message in response['Messages']:

            # Nachrichtenverarbeitung hier...
            if message['Body'] == os.environ["fail_message"]:
                try:
                    client_as = boto3.client('autoscaling')
                    response = client_as.start_instance_refresh(
                        AutoScalingGroupName=asg_name,
                        Strategy='Rolling',
                        Preferences={
                            'MinHealthyPercentage': 30,
                            'InstanceWarmup': 60,
                            'SkipMatching': False,
                            'ScaleInProtectedInstances': 'Ignore',
                            'StandbyInstances': 'Ignore',
                            # 'MaxHealthyPercentage': 200,  # not available in this boto3 version
                        },
                    )
                    print("asg_update_succeeded")
                except:
                    print("asg_update_failed")

            client_sqs.delete_message(
                QueueUrl=queue_url,
                ReceiptHandle=message['ReceiptHandle']
            )
    else:
        print("no messages in queue")
