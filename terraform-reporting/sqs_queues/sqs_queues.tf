# Create SQS queues -- Deadletter and message queue for Sumo messages
resource "aws_sqs_queue" "deadletter" {
  name                      = "${terraform.workspace}_${var.region}_deadletter"
  max_message_size          = var.max_message_size
  message_retention_seconds = 345600

  tags = {
    Environment = terraform.workspace
  }

  # Server side encryption
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
}

resource "aws_sqs_queue" "sqs_lambda_queue" {
  name                      = "${terraform.workspace}_${var.region}_sqs_lambda_queue"
  max_message_size          = var.max_message_size
  message_retention_seconds = 86400
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.deadletter.arn}\",\"maxReceiveCount\":3}"

  tags = {
    Environment = terraform.workspace
  }

  # Server side encryption
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
}

output "sqs_queue_arn" {
  value       = aws_sqs_queue.sqs_lambda_queue.arn
  description = "ARN of the SQS queue that triggers the Lambda SQS handler function"
}

output "deadletter_queue_arn" {
  value = aws_sqs_queue.deadletter.arn
  description = "ARN of the deadletter queue"
}