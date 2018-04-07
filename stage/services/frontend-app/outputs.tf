# Get DNS name of the ELB
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
