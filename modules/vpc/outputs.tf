output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.aws-vpc.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.aws-vpc.cidr_block
}

# Public Subnet IDs
output "public_subnet_az1_id" {
  description = "The ID of the public subnet in AZ1"
  value       = aws_subnet.public-az1.id
}

output "public_subnet_az2_id" {
  description = "The ID of the public subnet in AZ2"
  value       = aws_subnet.public-az2.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = [aws_subnet.public-az1.id, aws_subnet.public-az2.id]
}

# Service Subnet IDs
output "service_subnet_az1_id" {
  description = "The ID of the service subnet in AZ1"
  value       = aws_subnet.service-az1.id
}

output "service_subnet_az2_id" {
  description = "The ID of the service subnet in AZ2"
  value       = aws_subnet.service-az2.id
}

output "service_subnet_ids" {
  description = "List of IDs of service subnets"
  value       = [aws_subnet.service-az1.id, aws_subnet.service-az2.id]
}

# DB Subnet IDs
output "db_subnet_az1_id" {
  description = "The ID of the DB subnet in AZ1"
  value       = aws_subnet.db-az1.id
}

output "db_subnet_az2_id" {
  description = "The ID of the DB subnet in AZ2"
  value       = aws_subnet.db-az2.id
}

output "db_subnet_ids" {
  description = "List of IDs of DB subnets"
  value       = [aws_subnet.db-az1.id, aws_subnet.db-az2.id]
}

# Route Table IDs
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.aws-rt-pub.id
}

# Private Route Table IDs
output "private_service_route_table_az1_id" {
  description = "The ID of the private service route table for AZ1"
  value       = aws_route_table.aws-rt-pri-service-az1.id
}

output "private_service_route_table_az2_id" {
  description = "The ID of the private service route table for AZ2"
  value       = aws_route_table.aws-rt-pri-service-az2.id
}


# Private DB Route Table ID
output "private_db_route_table_id" {
  description = "The ID of the private DB route table"
  value       = aws_route_table.aws-rt-pri-db.id
}

output "private_service_route_table_ids" {
  description = "List of IDs of private service route tables"
  value       = [aws_route_table.aws-rt-pri-service-az1.id, aws_route_table.aws-rt-pri-service-az2.id]
}

# Gateway IDs
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.vpc-igw.id
}

output "nat_gateway_az1_id" {
  description = "The ID of the NAT Gateway in AZ1"
  value       = aws_nat_gateway.vpc-nat_az1.id
}

output "nat_gateway_az2_id" {
  description = "The ID of the NAT Gateway in AZ2"
  value       = aws_nat_gateway.vpc-nat_az2.id
}

# EIP
output "nat_eip_az1" {
  description = "The Elastic IP address for the NAT Gateway in AZ1"
  value       = aws_eip.nat-eip_az1.public_ip
}

output "nat_eip_az2" {
  description = "The Elastic IP address for the NAT Gateway in AZ2"
  value       = aws_eip.nat-eip_az2.public_ip
}

# CIDR blocks
output "public_subnet_az1_cidr" {
  description = "The CIDR block of the public subnet in AZ1"
  value       = aws_subnet.public-az1.cidr_block
}

output "public_subnet_az2_cidr" {
  description = "The CIDR block of the public subnet in AZ2"
  value       = aws_subnet.public-az2.cidr_block
}

output "service_subnet_az1_cidr" {
  description = "The CIDR block of the service subnet in AZ1"
  value       = aws_subnet.service-az1.cidr_block
}

output "service_subnet_az2_cidr" {
  description = "The CIDR block of the service subnet in AZ2"
  value       = aws_subnet.service-az2.cidr_block
}

output "db_subnet_az1_cidr" {
  description = "The CIDR block of the DB subnet in AZ1"
  value       = aws_subnet.db-az1.cidr_block
}

output "db_subnet_az2_cidr" {
  description = "The CIDR block of the DB subnet in AZ2"
  value       = aws_subnet.db-az2.cidr_block
}

# AZs
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.az
}