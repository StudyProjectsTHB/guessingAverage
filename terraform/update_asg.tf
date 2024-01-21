data "archive_file" "github_webhook_lambda_payload" {
  type = "zip"
  source_file = "${path.module}/user_data_files/github_webhook_lambda_script.py"
  output_path = "${path.module}/user_data_files/github_webhook_lambda_payload.zip"
}

data "archive_file" "ec2_lambda_payload" {
  type = "zip"
  source_file = "${path.module}/user_data_files/ec2_lambda_script.py"
  output_path = "${path.module}/user_data_files/ec2_lambda_payload.zip"
}

data "archive_file" "ami_lambda_payload" {
  type = "zip"
  source_file = "${path.module}/user_data_files/ami_lambda_script.py"
  output_path = "${path.module}/user_data_files/ami_lambda_payload.zip"
}

data "archive_file" "asg_instance_refresh_lambda_payload" {
  type = "zip"
  source_file = "${path.module}/user_data_files/asg_instance_refresh_lambda_script.py"
  output_path = "${path.module}/user_data_files/asg_instance_refresh_lambda_payload.zip"
}

data "aws_iam_role" "vocareum_lab_lambda_role" {
  name = "LabRole"
}

resource "aws_lambda_function" "github_webhook_lambda" {
  function_name = "GitHubWebhook"
  description = "GitHub Webhook"
  handler = "github_webhook_lambda_script.lambda_handler"
  role = data.aws_iam_role.vocareum_lab_lambda_role.arn
  filename = "${path.module}/user_data_files/github_webhook_lambda_payload.zip"
  source_code_hash = "${data.archive_file.github_webhook_lambda_payload.output_base64sha256}"
  runtime = "python3.12"
  timeout = 10

  environment {
      variables = {
          asg_name = aws_autoscaling_group.webserver-asg.name
          webhook_secret = random_password.webhook_secret.result
          ec2_instance_id = aws_instance.ec2_instance_for_ami.id
          sqs_ec2_queue_url = aws_sqs_queue.sqs_queue_for_ec2.url
          docker_repo = var.docker_credentials["docker_repository"]
      }
  }
}

resource "aws_apigatewayv2_api" "github_webhook_api_gateway" {
  name          = "GithubWebhookAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "github_webhook_route" {
  api_id    = aws_apigatewayv2_api.github_webhook_api_gateway.id
  route_key = "POST /${var.github_webhook_route}"

  target = "integrations/${aws_apigatewayv2_integration.github_webhook_integration.id}"
}

resource "aws_apigatewayv2_integration" "github_webhook_integration" {
  api_id = aws_apigatewayv2_api.github_webhook_api_gateway.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri = aws_lambda_function.github_webhook_lambda.invoke_arn
}

resource "aws_apigatewayv2_stage" "github_webhook_stage" {
  api_id        = aws_apigatewayv2_api.github_webhook_api_gateway.id
  name          = "$default"
  auto_deploy   = true
}

resource "aws_lambda_permission" "github_webhook_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.github_webhook_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.github_webhook_api_gateway.execution_arn}/*/*/${var.github_webhook_route}"
}

resource "aws_sqs_queue" "sqs_queue_for_ec2" {
    name = "SQSQueueForEC2"
    fifo_queue = false
#    content_based_deduplication = true
}

resource "aws_lambda_event_source_mapping" "sqs_ec2_lambda_ec2_event_source_mapping" {
  event_source_arn = aws_sqs_queue.sqs_queue_for_ec2.arn
  function_name    = aws_lambda_function.ec2_lambda.function_name
  batch_size       = 10
  enabled = true
}

resource "aws_lambda_permission" "sqs_ec2_lambda_permission" {
  statement_id  = "AllowSQSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_lambda.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.sqs_queue_for_ec2.arn
}

resource "aws_lambda_function" "ec2_lambda" {
  function_name = "EC2Lambda"
  description = "create AMI from EC2 instance"
  handler = "ec2_lambda_script.lambda_handler"
  role = data.aws_iam_role.vocareum_lab_lambda_role.arn
  filename = "${path.module}/user_data_files/ec2_lambda_payload.zip"
  source_code_hash = "${data.archive_file.ec2_lambda_payload.output_base64sha256}"
  runtime = "python3.12"
  timeout = 10

  environment {
    variables = {
      ec2_instance_id = aws_instance.ec2_instance_for_ami.id
      event_rule_name = aws_cloudwatch_event_rule.trigger_lambda_for_ami_rule.name
      sqs_ec2_queue_url = aws_sqs_queue.sqs_queue_for_ec2.id
      ami_lambda_arn = aws_lambda_function.ami_lambda.arn
      ami_tags = "[{\"Key\": \"created_by\",\"Value\": \"lambda\" },{\"Key\": \"guessingAverage\",\"Value\": \"webserver-ami\" }]"
    }
  }
}

resource "aws_sqs_queue" "sqs_queue_for_asg" {
  name = "SQSQueueForASG"
  fifo_queue = false
#  content_based_deduplication = true
}

resource "aws_lambda_function" "ami_lambda" {
  function_name = "AMILambda"
  description = "Check if AMI is available and start ASG instance refresh"
  handler = "ami_lambda_script.lambda_handler"
  role = data.aws_iam_role.vocareum_lab_lambda_role.arn
  filename = "${path.module}/user_data_files/ami_lambda_payload.zip"
  source_code_hash = "${data.archive_file.ami_lambda_payload.output_base64sha256}"
  runtime = "python3.12"
  timeout = 10

  environment {
    variables = {
      asg_name = aws_autoscaling_group.webserver-asg.name
      launch_template_id = aws_launch_template.webserver-lt.id
      event_rule_name = aws_cloudwatch_event_rule.trigger_lambda_for_ami_rule.name
      sqs_asg_queue_url = aws_sqs_queue.sqs_queue_for_asg.id
      fail_message = "ASGUpdateFailed"
    }
  }
}

resource "aws_cloudwatch_event_rule" "trigger_lambda_for_ami_rule" {
    name = "TriggerLambda"
    description = "Trigger Lambda to check if AMI is available"
#  dummy expression to not trigger the rule
    schedule_expression = "cron(0 0 1 1 ? 1970)"

}

resource "aws_cloudwatch_event_target" "trigger_lambda_target" {
    rule = aws_cloudwatch_event_rule.trigger_lambda_for_ami_rule.name
    arn = aws_lambda_function.ami_lambda.arn
    target_id = "TriggerLambdaTarget"
}

resource "aws_lambda_permission" "ami_lambda_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ami_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger_lambda_for_ami_rule.arn
}

resource "aws_lambda_function" "asg_instance_refresh_lambda" {
  function_name = "ASGInstanceRefreshLambda"
  description = "Refresh ASG instances"
  handler = "asg_instance_refresh_lambda_script.lambda_handler"
  role = data.aws_iam_role.vocareum_lab_lambda_role.arn
  filename = "${path.module}/user_data_files/asg_instance_refresh_lambda_payload.zip"
  source_code_hash = "${data.archive_file.asg_instance_refresh_lambda_payload.output_base64sha256}"
  runtime = "python3.12"
  timeout = 20

  environment {
    variables = {
      asg_name = aws_autoscaling_group.webserver-asg.name
      launch_template_id = aws_launch_template.webserver-lt.id
      fail_message = "ASGUpdateFailed"
      sqs_asg_queue_url = aws_sqs_queue.sqs_queue_for_asg.id
    }
  }
}

resource "aws_cloudwatch_event_rule" "asg_instance_refresh_rule" {
  name        = "ASGInstanceRefreshRule"
  description = "Triggers when ASG instance refresh is completed"

  event_pattern = jsonencode({
    "source" : ["aws.autoscaling"],
    "detail-type" : ["EC2 Auto Scaling Instance Refresh Succeeded"],
    "detail" : {
      "AutoScalingGroupName" : [aws_autoscaling_group.webserver-asg.name]
    }
  })
}

resource "aws_cloudwatch_event_target" "asg_instance_refresh_target" {
  rule = aws_cloudwatch_event_rule.asg_instance_refresh_rule.name
  arn = aws_lambda_function.asg_instance_refresh_lambda.arn
  target_id = "ASGInstanceRefreshTarget"
}

resource "aws_lambda_permission" "asg_instance_refresh_lambda_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asg_instance_refresh_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.asg_instance_refresh_rule.arn
}



resource "null_resource" "destroy_time_script" {
  triggers = {
    aws_access_key_id = var.aws_credentials["aws_access_key_id"]
    aws_secret_access_key = var.aws_credentials["aws_secret_access_key"]
    aws_session_token = var.aws_credentials["aws_session_token"]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "python ${path.module}/user_data_files/delete_all_amis.py"
    environment = {
      AWS_ACCESS_KEY_ID     = self.triggers.aws_access_key_id
      AWS_SECRET_ACCESS_KEY = self.triggers.aws_secret_access_key
      AWS_SESSION_TOKEN     = self.triggers.aws_session_token
      tags = "[{\"Key\": \"created_by\",\"Value\": \"lambda\" },{\"Key\": \"guessingAverage\",\"Value\": \"webserver-ami\" }]"
    }

  }
}
