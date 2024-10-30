


provider "aws" {

  profile = "default"         # This is your AWS CLI profile. Change it if you're using a different profile.

  region  = var.region        # The region is specified in the variables file

}

provider "aws" {
	alias = "acm"
	region = "us-east-1"

}
