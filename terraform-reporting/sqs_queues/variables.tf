variable "max_message_size" {
  default = 2048
}

variable "kms_data_key_reuse_period_seconds" {
  default = 300
}

variable "region" {
  type = string
}