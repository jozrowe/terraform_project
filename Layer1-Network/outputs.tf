output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_1" {
  value = aws_subnet.public_subnet_1.id
}

output "public_subnet_2" {
  value = aws_subnet.public_subnet_2.id
}

output "private_subnet_1" {
  value = aws_subnet.private_subnet_1.id
  
}

output "nat_elastic_ip_1" {
  value = aws_eip.elastic_ip_1.public_ip
}

output "private_subnet_2" {
  value = aws_subnet.private_subnet_2.id
}

output "nat_elastic_ip_2" {
  value = aws_eip.elastic_ip_2.public_ip
}
