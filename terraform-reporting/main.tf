# Instantiate the AWS provider to give access to AWS resource types
provider "aws" {
  version                 = "~> 2.0"
  region                  = var.region
  shared_credentials_file = var.api_key_file
  profile                 = "default"
}

# Region variable is defined in the command line during Terraform apply
module "lambda_functions" {
  source = ".\\lambda_functions"
  region = var.region

  # Need this so I can pass it through to Lambda module
  event_source_arn = module.sqs_queues.sqs_queue_arn
  deadletter_arn   = module.sqs_queues.deadletter_queue_arn
}

module "athena_database" {
  source = ".\\athena_database"
  region = var.region
}

module "sqs_queues" {
  source = ".\\sqs_queues"
  region = var.region
}