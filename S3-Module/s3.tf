#1. S3 bucket
resource "aws_s3_bucket" "backend" {
  count = var.create_vpc ? 1 : 0

  bucket = lower("bootcamp32-${var.env}-${random_integer.backend.result}")

  tags = {
    Name        = "my backend"
    Environment = "Dev"
  }
}

#2. KMS for bucket encryption
resource "aws_kms_key" "mykey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

#3. Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backend" {
  bucket = aws_s3_bucket.backend[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

#4. Random integer
resource "random_integer" "backend" {
  max = 100
  min = 1

  keepers = {
    bucket_owner = var.env
  }
}

#5 Bucket versioning
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.backend[0].id
  versioning_configuration {
    status = var.versioning
  }
}