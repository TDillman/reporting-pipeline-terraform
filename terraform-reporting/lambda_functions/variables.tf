variable "runtime" {
  default = "python3.8"
  description = "boto3-1.10.2 botocore-1.13.2 on Amazon Linux 2"
}

variable "sumo_api_key_arn" {
  type= map(string)

  default = {
    us-east-1 = "arn:aws:secretsmanager:us-east-1:338252700317:secret:sumo_api_key-NsViyu"
    eu-west-1 = "arn:aws:secretsmanager:eu-west-1:338252700317:secret:sumo_api_key_eu-Ujd6yT"
  }
}

/*variable "source_s3_bucket" {
  default = "bitdefender_source_bucket"
}

variable "source_s3_key" {
  default = "source"
}*/

variable "event_source_arn" {}

variable "deadletter_arn" {}

variable "region" {
  type = string
}