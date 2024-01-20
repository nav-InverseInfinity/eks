output "vpc_id" {
  value = aws_vpc.dev.id
}
output "public_subnet" {
  value = [values(aws_subnet.public-subnet)[0].id, values(aws_subnet.public-subnet)[1].id]
}
