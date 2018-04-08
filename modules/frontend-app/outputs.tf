# Get DNS name of the ELB
output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

# Get ASG name
output "asg_name" {
  value = "${aws_autoscaling_group.autoscaling_group.name}"
}
