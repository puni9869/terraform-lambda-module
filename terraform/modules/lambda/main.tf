#  Lambda Module
resource "aws_lambda_function" "lambda" {
  description      = var.description
  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  publish          = true
  runtime          = "go1.x"
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

  #  lifecycle {
  #    prevent_destroy = true
  #  }

  tags       = var.tags
  depends_on = [
    aws_cloudwatch_log_group.log_groups,
  ]
}

#resource "aws_lambda_alias" "live" {
#  name             = "live"
#  description      = "set a live alias for ${var.function_name}"
#  function_name    = aws_lambda_function.lambda.arn
#  function_version = aws_lambda_function.lambda.version
#}


resource "aws_cloudwatch_log_group" "log_groups" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 400
}


## Event Bridge Cron
resource "aws_cloudwatch_event_rule" "rule" {
  count               = length(var.event_rules)
  name                = "${var.function_name}-${var.event_rules[count.index].name}-event"
  description         = "Fires event for ${var.function_name} lambda"
  schedule_expression = var.event_rules[count.index].value
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "target" {
  count = length(var.event_rules)
  rule  = aws_cloudwatch_event_rule.rule[count.index].name
  arn   = aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "cloudwatch_to_call_event" {
  count         = length(var.event_rules)
  statement_id  = "AllowExecutionFromCloudWatch-rule-${var.event_rules[count.index].name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.rule[count.index].arn
}
