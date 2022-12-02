provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {
  provider = aws
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


module "lambda" {
  source        = "./modules/lambda"
  function_name = "start0"
  role_arn      = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  filename      = "Multiplelambda.zip"
  environment   = {
    "variables" : {
      "Hello" : "Ok"
    }
  }
  event_rules = [
    {
      "name": "one-hour",
      "value": "rate(1 hour)"
    },
    {
      "name": "two-hour",
      "value": "rate(2 hours)"
    }
  ]
}


#module "lambda2" {
#  source        = "./modules/lambda"
#  function_name = "start1"
#  role_arn      = aws_iam_role.iam_for_lambda.arn
#  handler       = "lambda_function.lambda_handler"
#  filename      = "Multiplelambda.zip"
#}