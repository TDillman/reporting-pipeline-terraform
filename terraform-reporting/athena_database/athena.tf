resource "aws_kms_key" "s3_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_kms_key" "athena_key" {
  description             = "Athena KMS Key"
  deletion_window_in_days = 10
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_s3_bucket" "reporting_bucket" {
  bucket_prefix = "${terraform.workspace}-${var.region}-reporting-bucket-"
  acl           = "private"
  force_destroy = true
  region        = var.region

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_s3_bucket" "query_output_bucket" {
  bucket_prefix = "${terraform.workspace}-${var.region}-query-bucket-"
  acl           = "private"
  force_destroy = true
  region        = var.region

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_athena_workgroup" "athena_workgroup" {
  name = "reporting_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.query_output_bucket.bucket}/output/"

      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = aws_kms_key.athena_key.arn
      }
    }
  }
  tags = {
   "Environment" = terraform.workspace
  }
}

resource "aws_athena_database" "reporting_db" {
  name   = "reporting"
  bucket = aws_s3_bucket.reporting_bucket.id
}