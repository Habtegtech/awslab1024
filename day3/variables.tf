


variable "region" {
  description = "Region for my manifest. The S3 bucket will be created in this region"
  default     = "us-east-1"  
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
