# Variable to export the subnet IDs
output "public_subnet_ids" {
  value = [
    "${aws_subnet.public-2a.id}",
    "${aws_subnet.public-2b.id}",
    "${aws_subnet.public-2c.id}"
  ]
}
