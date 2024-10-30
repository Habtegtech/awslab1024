


provider "aws" {

  region = "us-east-1"  # SES is only available in certain regions; adjust as necessary.

}



# SES Domain Verification

resource "aws_ses_domain_identity" "domain" {

  domain = var.domain_name

}



# SES DKIM

resource "aws_ses_domain_dkim" "dkim" {

  domain = aws_ses_domain_identity.domain.domain

}



# SNS Topic

resource "aws_sns_topic" "sns_topic" {

  name = "sns-ses-test"

}



# SNS Subscription

resource "aws_sns_topic_subscription" "email_subscription" {

  topic_arn = aws_sns_topic.sns_topic.arn

  protocol  = "email"

  endpoint  = var.email_address

}


