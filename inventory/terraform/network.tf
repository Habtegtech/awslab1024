
/*
 * Setup network, including VPC, Subnets, Route Tables, and Internet Gateway
 *
 * Specifications:
 *    VPC CIDR: 10.100.0.0/16 (var.vpc_cidr)
 *    Subnet CIDR: 10.100.1.0/24 (var.subnet_cidr)
 *    Subnet AZ: (data.aws_availability_zones.azs.names[0])
 *    Route Table: Default route to IGW
 *    Security Group: Allow ping, 80, 8080, 22
 *    NACL: Allow ping, 8080, 22 ; Deny 3389
 */


/***********************************
 * Pull in AZs for the Region
 ***********************************/

data "aws_availability_zones" "azs" {
  state = "available"
}

output "availability_zone" {
  value = element(data.aws_availability_zones.azs.names, 0)
}

/***********************************
 * VPC 
 ***********************************/

 resource "aws_vpc" "inventory" {
  cidr_block           = var.vpc_cidr  # VPC CIDR block, e.g., 10.100.0.0/16
  instance_tenancy     = "default"     # Default instance tenancy (no dedicated instances)
  enable_dns_support   = true          # Enable DNS support in the VPC
  enable_dns_hostnames = true          # Enable DNS hostnames in the VPC

  tags = {
    Name = "inventory-${terraform.workspace}"  # Tag for identifying the VPC
  }
}

/***********************************
 * Internet Gateway (IGW) for the VPC
 ***********************************/

# Create an internet gateway to allow outbound traffic from the VPC to the internet
resource "aws_internet_gateway" "inventory" {
  vpc_id = aws_vpc.inventory.id  # Attach the gateway to the created VPC

  tags = {
    Name = "inventory-${terraform.workspace}"  # Tag for identifying the IGW
  }
}
/***********************************
 * Subnets in first AZ of the region
 ***********************************/

 resource "aws_subnet" "inventory" {
  vpc_id            = aws_vpc.inventory.id  # Associate subnet with the VPC
  cidr_block        = var.subnet_cidr       # Subnet CIDR block, e.g., 10.100.1.0/24
  availability_zone = data.aws_availability_zones.azs.names[0]  # First availability zone

  map_public_ip_on_launch = true  # Automatically assign a public IP on launch

  tags = {
    Name = "inventory-az1-${terraform.workspace}"  # Tag for identifying the subnet
  }
}

/***********************************
 * Route Table, Default to IGW
 ***********************************/

resource "aws_route_table" "inventory" {
  vpc_id = aws_vpc.inventory.id  # Attach route table to the VPC

  tags = {
    Name = "inventory-${terraform.workspace}"  # Tag for identifying the route table
  }
}

# Add default route to the route table, directing outbound traffic to the Internet Gateway (IGW)
resource "aws_route" "inventory2igw" {
  route_table_id         = aws_route_table.inventory.id  # Attach route to the defined route table
  destination_cidr_block = "0.0.0.0/0"  # Default route to all IPs (internet)
  gateway_id             = aws_internet_gateway.inventory.id  # Set IGW as the gateway
}

# Attach the created route table to the subnet so that the subnet follows the defined routes
resource "aws_route_table_association" "inventory" {
  subnet_id      = aws_subnet.inventory.id  # Subnet to associate with the route table
  route_table_id = aws_route_table.inventory.id  # Route table to associate
}
/***********************************
 * Network Access Control List (NACL)
 * Allow ping, ssh, 8080, deny RDP
 ***********************************/
resource "aws_network_acl" "inventory" {
  vpc_id     = aws_vpc.inventory.id  # Attach NACL to the VPC
  subnet_ids = [aws_subnet.inventory.id]  # Apply to the subnet

  # Ingress rules (incoming traffic)
  ingress {
    rule_no    = 10
    from_port  = 0
    to_port    = 0
    icmp_type  = 8  # Allow ICMP echo request (ping)
    icmp_code  = -1
    cidr_block = "0.0.0.0/0"  # Allow from any IP
    protocol   = "icmp"
    action     = "allow"
  }
  ingress {
    rule_no    = 100
    from_port  = 22  # Allow SSH (port 22)
    to_port    = 22
    cidr_block = "0.0.0.0/0"  # Allow from any IP
    protocol   = "tcp"
    action     = "allow"
  }
  ingress {
    rule_no    = 110
    from_port  = 8080  # Allow HTTP service on port 8080
    to_port    = 8080
    cidr_block = "0.0.0.0/0"  # Allow from any IP
    protocol   = "tcp"
    action     = "allow"
  }
  ingress {
    rule_no    = 120
    from_port  = 3389  # Deny RDP (port 3389)
    to_port    = 3389
    cidr_block = "0.0.0.0/0"  # Deny from any IP
    protocol   = "tcp"
    action     = "deny"
  }

  # Egress rules (outgoing traffic)
  egress {
    rule_no    = 10
    from_port  = 0
    to_port    = 0
    icmp_type  = 0  # Allow ICMP echo reply (ping reply)
    icmp_code  = -1
    cidr_block = "0.0.0.0/0"  # Allow to any IP
    protocol   = "icmp"
    action     = "allow"
  }
  egress {
    rule_no    = 120
    from_port  = 49152  # Allow dynamic app ports for outbound traffic
    to_port    = 65535
    cidr_block = "0.0.0.0/0"  # Allow to any IP
    protocol   = "tcp"
    action     = "allow"
  }
  egress {
    rule_no    = 130
    from_port  = 80  # Allow HTTP outbound (for apt-get)
    to_port    = 80
    cidr_block = "0.0.0.0/0"  # Allow to any IP
    protocol   = "tcp"
    action     = "allow"
  }
  egress {
    rule_no    = 140
    from_port  = 443  # Allow HTTPS outbound
    to_port    = 443
    cidr_block = "0.0.0.0/0"  # Allow to any IP
    protocol   = "tcp"
    action     = "allow"
  }

  tags = {
    Name = "inventory-${terraform.workspace}"  # Tag for identifying the NACL
  }
}

/***********************************
 * Security Group, used by any instance
 ***********************************/
# Create a security group that allows specific inbound and outbound traffic
resource "aws_security_group" "inventory" {
  name        = "inventory-sg"
  description = "Allow SSH, PING, HTTP, and App HTTP traffic"
  vpc_id      = aws_vpc.inventory.id  # Associate SG with the VPC

  # Ingress rules (allow inbound traffic)
  ingress {
    description = "Allow ping (ICMP)"
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow ping from any source
  }
  ingress {
    description = "Allow SSH (port 22)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any source
  }
  ingress {
    description = "Allow HTTP (port 80)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any source
  }
}