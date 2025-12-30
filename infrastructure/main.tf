provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "event-driven-pipeline-bucket"
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

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_s3_logs_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.pipeline_bucket.arn,
          "${aws_s3_bucket.pipeline_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "capture_lambda" {
  function_name = "data-capture-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_capture.zip"
}

resource "aws_lambda_function" "report_lambda" {
  function_name = "daily-report-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "report_lambda.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_report.zip"
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily-report-trigger"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "report_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "reportLambda"
  arn       = aws_lambda_function.report_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.report_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
