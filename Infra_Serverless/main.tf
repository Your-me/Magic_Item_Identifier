# ZIP the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_magic_item_identifier.py"
  output_path = "${path.module}/lambda_magic_item_identifier.zip"
}

# Create new IAM role with a different name
resource "aws_iam_role" "lambda_role_new" {
  name = "magic_items_lambda_role_new"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda function using the new role
resource "aws_lambda_function" "magic_items_identifier_api" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "magic-items-identifier-api"
  role          = aws_iam_role.lambda_role_new.arn
  handler       = "lambda_magic_item_identifier.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      LOG_LEVEL = "INFO"
    }
  }
}

# CloudWatch Logs policy
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role_new.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# API Gateway
resource "aws_api_gateway_rest_api" "magic_items_identifier_api" {
  name = "magic_items_identifier_api"
}

resource "aws_api_gateway_resource" "item" {
  rest_api_id = aws_api_gateway_rest_api.magic_items_identifier_api.id
  parent_id   = aws_api_gateway_rest_api.magic_items_identifier_api.root_resource_id
  path_part   = "item"
}

resource "aws_api_gateway_method" "get_item" {
  rest_api_id   = aws_api_gateway_rest_api.magic_items_identifier_api.id
  resource_id   = aws_api_gateway_resource.item.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.name" = true
  }
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.magic_items_identifier_api.id
  resource_id = aws_api_gateway_resource.item.id
  http_method = aws_api_gateway_method.get_item.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.magic_items_identifier_api.invoke_arn
}

#Calling Current ID
data "aws_caller_identity" "current" {}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.magic_items_identifier_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.magic_items_identifier_api.id}/*/${aws_api_gateway_method.get_item.http_method}${aws_api_gateway_resource.item.path}"
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.magic_items_identifier_api.id

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway stage
resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.magic_items_identifier_api.id
  stage_name    = "dev"
}

# Output the API URL
output "api_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/item"
}