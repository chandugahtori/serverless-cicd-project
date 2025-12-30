provider "aws" {
region = "us-east-1"
}


resource "aws_iam_role" "lambda_role" {
name = "lambda_execution_role"
assume_role_policy = jsonencode({
Version = "2012-10-17"
Statement = [{
Effect = "Allow"
Principal = {
Service = "lambda.amazonaws.com"
}
Action = "sts:AssumeRole"
}]
})
}


resource "aws_lambda_function" "serverless_app" {
function_name = "serverless-ci-cd-demo"
runtime = "python3.9"
handler = "app.lambda_handler"
role = aws_iam_role.lambda_role.arn
filename = "../lambda/app2.zip"
}