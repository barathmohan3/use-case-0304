output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_1_id" {
  value = aws_subnet.public.id
}

output "subnet_2_id" {
  value = aws_subnet.public_2.id
}