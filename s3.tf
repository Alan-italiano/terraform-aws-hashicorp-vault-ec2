# Create S3 Bucket to store vault backup files
resource "aws_s3_bucket" "vault" {
  bucket = var.aws_s3_bucket
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "vault" {
  bucket = aws_s3_bucket.vault.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "vault" {
  depends_on = [aws_s3_bucket_ownership_controls.vault]

  bucket = aws_s3_bucket.vault.id
  acl    = "private"
}
