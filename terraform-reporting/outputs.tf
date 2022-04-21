output "function_sqs_handler_arn" {
  value = module.lambda_functions.sqs_handler_arn
}

output "funciton_lambda_scheduler_arn" {
  value = module.lambda_functions.lambda_scheduler_arn
}

output "hash_sqs_handler_source" {
  value = module.lambda_functions.sqs_handler_source_hash
}

output "hash_lambda_scheduler_source" {
  value = module.lambda_functions.lambda_scheduler_source_hash
}