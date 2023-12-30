data "archive_file" "github_webhook_lambda_payload" {
  type = "zip"
  source_file = "${path.module}/user_data_files/github_webhook_lambda_skript.py"
  output_path = "${path.module}/user_data_files/github_webhook_lambda_payload.zip"
}

data "aws_iam_role" "vocareum_lab_lambda_role" {
  name = "LabRole"
}

resource "aws_lambda_function" "github_webhook_lambda" {

  function_name = "GitHubWebhook"
  description = "GitHub Webhook"
  handler = "github_webhook_lambda_skript.lambda_handler"
  role = data.aws_iam_role.vocareum_lab_lambda_role.arn
  filename = "${path.module}/user_data_files/github_webhook_lambda_payload.zip"
  source_code_hash = "${data.archive_file.github_webhook_lambda_payload.output_base64sha256}"
  runtime = "python3.12"
  timeout = 5

    environment {
        variables = {
            asg_name = aws_autoscaling_group.webserver-asg.name
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


