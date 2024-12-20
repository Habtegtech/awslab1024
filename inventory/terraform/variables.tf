
variable "region" {
  description = "AWS Region"
  type        = string
}

variable "domain" {
  type    = string
  default = "habtamu-dev.com"
}

variable "alarm_email" {
  type    = string
  default = "habtamu.tegegne@techconsulting.tech"
}

variable "route53_zone_id" {
  type    = string
  default = "Z09655993PVRWEK93CPPY"
}

variable "service_port" {
  type    = number
  default = "8080"
}

variable "vpc_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.100.1.0/24"
}

variable "inventory_server_private_ip" {
  type    = string
  default = "10.100.1.10"
}

variable "instance_type" {
  type    = string
  default = "t4g.nano"
}

variable "guardduty_name" {
  type    = string
  default = "guardduty"
}
