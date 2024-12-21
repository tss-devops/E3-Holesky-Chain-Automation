output "public_subnet_id" {
  value = aws_subnet.eth_public_subnet.id
}

output "vpc_id" {
  value = aws_vpc.eth_vpc.id
}

output "public_subnet_cidr" {
  value = aws_subnet.eth_public_subnet.cidr_block
}

output "private_subnet_cidrs" {
  value = aws_subnet.eth_private_subnet[*].cidr_block
}

output "private_subnet_ids" {
  value = aws_subnet.eth_private_subnet[*].id
}