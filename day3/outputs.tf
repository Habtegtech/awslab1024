


output "bucket_fqdn" {
  value = aws_s3_bucket.my_bucket.bucket_domain_name  # Outputs the fully qualified domain name of the S3 bucket
}
