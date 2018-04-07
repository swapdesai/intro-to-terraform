# Export id of the VPC
output "vpc_id" {
  value = "${aws_vpc.stage.id}"
}

# Export the subnet IDs
output "public_subnet_ids" {
  value = [
    "${aws_subnet.public-2a.id}",
    "${aws_subnet.public-2b.id}",
    "${aws_subnet.public-2c.id}"
  ]
}
