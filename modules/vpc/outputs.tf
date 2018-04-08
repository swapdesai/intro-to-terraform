# Export id of the VPC
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

# Export the subnet IDs
output "public_subnet_ids" {
  value = [
    "${aws_subnet.public-a.id}",
    "${aws_subnet.public-b.id}",
    "${aws_subnet.public-c.id}"
  ]
}
