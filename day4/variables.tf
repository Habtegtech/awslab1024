



variable "domain" {

  description = "The domain name to verify with SES"

  type        = string

}



variable "alarms_email" {

  description = "The email address to subscribe to the SNS topic"

  type        = string

}



variable "region" {

  description = "The AWS region"

  default     = "us-east-1"  

}




