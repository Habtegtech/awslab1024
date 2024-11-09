
/*
 * Before running your Terraform, run keypairgen.sh in this directory
 * to generate your key pair
 *
 * Specification:
 *  run keypairgen.sh and uuse ../etc/ec2user.pub
 *  EC2 Instance bringing together everything we've defined
 *  Empty Instance Profie
 */


/***************************
 * Key Pair for Access
 ***************************/

 resource "aws_key_pair" "inventory" {
  key_name   = "inventoryServerKey-${terraform.workspace}"
  public_key = file("${path.module}/../ansible/ec2user.pub")
 }

/***************************
 * Instance Section
 ***************************/

resource "aws_instance" "inventory_server" {
  instance_type          = var.instance_type                // Defines the instance type (e.g., t2.micro), provided by a variable
  ami                    = data.aws_ami.ubuntu_2404.id      // Uses a specific Amazon Machine Image (AMI) for Ubuntu 24.04, defined in data sources
  vpc_security_group_ids = [aws_security_group.inventory.id] // Associates the instance with a security group by its ID
  iam_instance_profile   = aws_iam_instance_profile.inventory_server.id // Attaches an IAM instance profile for instance permissions
  key_name               = aws_key_pair.inventory.key_name  // Sets the key pair created above for SSH access
  subnet_id              = aws_subnet.inventory.id          // Specifies the subnet for network placement within the VPC
  #private_ip             = var.inventory_server_private_ip  // Sets a private IP for the instance, specified by a variable

  tags = {
    Name      = "inventory-${terraform.workspace}"         // Tags the instance with a name that includes the workspace name
    Inspector = "yes"                                      // Adds a custom tag "Inspector" to the instance
  }
}

output "inventory_public_ip" {
  value = aws_instance.inventory_server.public_ip          // Outputs the public IP address of the instance
}

output "inventory_url" {
  value = join("", ["http://", aws_instance.inventory_server.public_ip, // Outputs a constructed URL to access the instance
  ":", var.service_port])                                // Includes the port defined by the variable 'service_port' for direct access
}