




resource "aws_ses_domain_identity" "main" {

  domain = var.domain  # Replace with your domain

}



resource "aws_ses_domain_dkim" "main" {

  domain = aws_ses_domain_identity.main.domain

}



resource "aws_sns_topic" "sns_topic" {

  name = "sns-ses-test"

}



resource "aws_sns_topic_subscription" "sns_subscription" {

  topic_arn = aws_sns_topic.sns_topic.arn

  protocol  = "email"

  endpoint  = var.alarms_email  # Email to subscribe

}


