data "aws_secretsmanager_secret_version" "sumo_api_key" {
  secret_id = lookup(var.sumo_api_key_arn, var.region)
}

resource "aws_iam_role" "lambda_role" {
  name               = "${terraform.workspace}_${var.region}-lambda_role"
  assume_role_policy = file("${path.module}\\assume_role_policy.json")
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${terraform.workspace}_${var.region}-lambda_policy"
  policy = file("${path.module}\\lambda_policy.json")
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  role        = aws_iam_role.lambda_role.name
  policy_arn  = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_event_source_mapping" "sqs_source_trigger" {
  event_source_arn = var.event_source_arn
  function_name    = aws_lambda_function.sqs_handler.arn

  # batch_size is the largest number of records that Lambda will retrieve from SQS. Default is 10
  batch_size = 1
}

resource "aws_lambda_function" "lambda_scheduler" {
  filename      = ".\\lambda_functions\\lambda_scheduler_source.zip"
  function_name = "${terraform.workspace}_${var.region}_lambda_scheduler"
  role          = aws_iam_role.lambda_role.arn
  memory_size   = 128
  timeout       = 3

  # Can tweak this if we start pushing Sumo too fast. -1 is no concurrency limits
  reserved_concurrent_executions = -1

  # Need to get entry point from Lambda function when it's done
  handler = "lambda.handler"
  runtime = var.runtime

  source_code_hash = filebase64sha256(".\\lambda_functions\\lambda_scheduler_source.zip")

  environment {
    variables = {
      sumo_api_key    = jsondecode(data.aws_secretsmanager_secret_version.sumo_api_key.secret_string)["sumo_api_key"]
      sumo_api_secret = jsondecode(data.aws_secretsmanager_secret_version.sumo_api_key.secret_string)["sumo_api_secret"]
    }
  }
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_lambda_function" "sqs_handler" {
  filename      = ".\\lambda_functions\\lambda_sqs_handler_source.zip"
  function_name = "${terraform.workspace}_${var.region}_sqs_handler"
  role          = aws_iam_role.lambda_role.arn
  memory_size   = 128
  timeout       = 3

  # Can tweak this if we start pushing Sumo too fast. -1 is no concurrency limits
  reserved_concurrent_executions = -1

  # Need to get entry point from Lambda function when it's done
  handler = "lambda.handler"
  runtime = var.runtime

  source_code_hash = filebase64sha256(".\\lambda_functions\\lambda_sqs_handler_source.zip")

  dead_letter_config {
    target_arn = var.deadletter_arn
  }

  environment {
    variables = {
      sumo_api_key    = jsondecode(data.aws_secretsmanager_secret_version.sumo_api_key.secret_string)["sumo_api_key"]
      sumo_api_secret = jsondecode(data.aws_secretsmanager_secret_version.sumo_api_key.secret_string)["sumo_api_secret"]
    }
  }
  tags = {
   "Environment" = terraform.workspace
  }
}

output "lambda_scheduler_arn" {
  value = aws_lambda_function.lambda_scheduler.arn
}

output "sqs_handler_arn" {
  value = aws_lambda_function.sqs_handler.arn
}

output "lambda_scheduler_source_hash" {
  value = aws_lambda_function.lambda_scheduler.source_code_hash
}

output "sqs_handler_source_hash" {
  value = aws_lambda_function.sqs_handler.source_code_hash
}