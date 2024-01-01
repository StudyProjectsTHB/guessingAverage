import json
import boto3
from datetime import datetime, timedelta
import os
import hmac
import hashlib


def lambda_handler(event, context):
    # TODO implement
    print(event)
    # print(context)
    # print(event["headers"]["x-github-event"])
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
        # print(run_status['workflow_run'])
        # print(run_status['workflow_run']["conclusion"])
        if (run_status['workflow_run']["status"] == 'completed' and
                run_status['workflow_run']["conclusion"] == 'success'):
            client_as = boto3.client('autoscaling')
            asg_name = os.environ["asg_name"]
            try:
                response = client_as.start_instance_refresh(
                    AutoScalingGroupName=asg_name,
                    Strategy='Rolling',
                    Preferences={
                        'MinHealthyPercentage': 30,
                        'InstanceWarmup': 150,
                        'SkipMatching': False,
                        'ScaleInProtectedInstances': 'Ignore',
                        'StandbyInstances': 'Ignore',
                        # 'MaxHealthyPercentage': 200, not available in this boto3 version
                    },
                )
                return {
                    'statusCode': 200,
                    'body': json.dumps('triggered asg refresh')
                }
            except Exception as e:
                print(e)
                return {
                    'statusCode': 500,
                    'body': json.dumps(str(e))
                }

                # response = client_as.describe_auto_scaling_groups(AutoScalingGroupNames=[asg_name])
                # desired_capacity = response['AutoScalingGroups'][0]['DesiredCapacity']
                # warmup_clients = response['AutoScalingGroups'][0]['DefaultCooldown']
                # # print(desired_capacity, warmup_clients)
                # client_ev = boto3.client('events')
                #
                # # # Berechnen der Zeit für den nächsten Trigger
                # trigger_time = datetime.now() + timedelta(seconds=desired_capacity*warmup_clients * 2 + 60)
                # trigger_time_str = trigger_time.strftime('%M %H %d %m ? %Y')
                #
                # # # Erstellen des EventBridge-Rules
                # rule_name = f"await_asg_refresh"
                # print('cron({})'.format(trigger_time_str))
                # client_ev.put_rule(
                #     Name=rule_name,
                #     ScheduleExpression='cron({})'.format(trigger_time_str)
                # )
                # # max 8192 chars
                # run_status = {k: v for k, v in run_status.items() if k in ['workflow_run', 'action']}
                # run_status["workflow_run"] = {k: v for k, v in run_status["workflow_run"].items() if k in ['status', 'conclusion']}
                #
                #
                # data = {"headers": event["headers"], "body": run_status}
                # # # Hinzufügen der Lambda-Funktion als Ziel für die Regel
                # client_ev.put_targets(
                #     Rule=rule_name,
                #     Targets=[{
                #         'Id': '1',
                #         'Arn': context.invoked_function_arn,
                #         'Input': json.dumps(data),
                #     }]
                #
                # )
                # print(rule_name)
    return {
        'statusCode': 200,
        'body': json.dumps('update received')
    }


def verify_signature(secret, payload, signature):
    mac = hmac.new(secret.encode('utf-8'), msg=payload, digestmod=hashlib.sha1)
    expected_signature = "sha1=" + mac.hexdigest()
    return hmac.compare_digest(expected_signature, signature)