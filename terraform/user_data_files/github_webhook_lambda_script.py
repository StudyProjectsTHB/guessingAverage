import json
import boto3
from datetime import datetime, timedelta
import os
import hmac
import hashlib


def lambda_handler(event, context):
    print(event)
    if event["headers"]["x-github-event"] == "workflow_run":
        secret = os.environ["webhook_secret"]
        signature = event["headers"]["x-hub-signature"]
        body = event["body"].encode('utf-8')

        if not verify_signature(secret, body, signature):
            return {
                'statusCode': 403,
                'body': json.dumps('Invalid GitHub signature')
            }

        if type(event["body"]) == type("str"):
            run_status = json.loads(event["body"])
        else:
            run_status = event["body"]
        if (run_status['workflow_run']["status"] == 'completed' and
                run_status['workflow_run']["conclusion"] == 'success'):
            ssm_client = boto3.client('ssm')
            ec2_instance_id = os.environ["ec2_instance_id"]

            commands = [
                'sudo apt update',
                'sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y',
                f'sudo docker rmi {os.environ["docker_repo"]}',
                f'sudo docker pull {os.environ["docker_repo"]}',
                f'aws sqs send-message --queue-url {os.environ["sqs_ec2_queue_url"]} --message-body {os.environ["ec2_instance_id"]} --region us-east-1',
            ]

            response = ssm_client.send_command(
                InstanceIds=[ec2_instance_id],
                DocumentName='AWS-RunShellScript',
                Parameters={'commands': commands}
            )
            return {
                'statusCode': 200,
                'body': json.dumps('triggered asg refresh')
            }
    return {
        'statusCode': 200,
        'body': json.dumps('update received')
    }


def verify_signature(secret, payload, signature):
    mac = hmac.new(secret.encode('utf-8'), msg=payload, digestmod=hashlib.sha1)
    expected_signature = "sha1=" + mac.hexdigest()
    return hmac.compare_digest(expected_signature, signature)
