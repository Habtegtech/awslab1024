


#!/bin/bash
#
#
#Get the hosted zone ID
	hosted_zone=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text | cut -d/ -f3)
#
	echo "Importing Zone ID ${hosted_zone}"
#
	terraform import aws_route53_zone.main ${hosted_zone}
#
#
#Show the imported hosted zone details
	echo "Successfully imported the Route 53 Hosted Zone."
	echo "Displaying the details of the imported zone:"
#
	terraform state show aws_route53_zone.main
#
#
