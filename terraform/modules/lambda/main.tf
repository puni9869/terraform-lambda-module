#  Lambda Module
resource "aws_lambda_function" "lambda" {
  description      = var.description
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  publish          = true
  runtime          = "python3.9"
  timeout          = 10
  memory_size      = 128
  filename         = "${path.module}/../../../${var.filename}"
  source_code_hash = filebase64sha256("${path.module}/../../../${var.filename}")

  tracing_config {
    mode = "Active"
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = environment.value.variables
    }
  }


  tags       = var.tags
  depends_on = [
    aws_cloudwatch_log_group.log_groups,
  ]
}

resource "aws_lambda_alias" "live" {
  name             = "live"
  description      = "set a live alias for ${var.function_name}"
  function_name    = aws_lambda_function.lambda.arn
  function_version = aws_lambda_function.lambda.version
}


resource "aws_cloudwatch_log_group" "log_groups" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 400
}


## Event Bridge Cron
#resource "aws_cloudwatch_event_rule" "every_one_hour" {
#  name                = "addonsbilling-startUsageImport-everyOneHour"
#  description         = "Fires every one hour addonsbilling-startUsageImport lambda"
#  schedule_expression = "rate(1 hour)"
#  tags                = var.tags
#}
#
#resource "aws_cloudwatch_event_target" "start_usage_import_every_one_hour" {
#  rule = aws_cloudwatch_event_rule.every_one_hour.name
#  arn  = aws_lambda_function.start_usage_import.arn
#}
#
#resource "aws_lambda_permission" "cloudwatch_to_call_start_usage_import" {
#  statement_id  = "AllowExecutionFromCloudWatch"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.start_usage_import.function_name
#  principal     = "events.amazonaws.com"
#  source_arn    = aws_cloudwatch_event_rule.every_one_hour.arn
#}
