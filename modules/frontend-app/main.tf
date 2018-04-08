# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Deploy a Single EC2 instance / server cluster
# This template runs a simple "Hello, World" web server on cluster of EC2 instances on AWS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# Configure the cloud provider
# ------------------------------------------------------------------------------
provider "aws" {
  region = "ap-southeast-2"
}

# ------------------------------------------------------------------------------
# Configure the AWS launch configuration
# ------------------------------------------------------------------------------
resource "aws_launch_configuration" "launch_configuration" {
  name = "${var.environment_name}-launch-configuration"

  image_id        = "ami-d38a4ab1"
  instance_type   = "t2.micro"

  # Security group to be used by the EC2 instance
  # Use interpolation feature of Terraform - syntax is “${TYPE.NAME.ATTRIBUTE}”
  security_groups = ["${aws_security_group.ec2_security_group.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  # Create a new EC2 instance before deleting the old one
  # Catch - Set this on every resource that this resource depends on
  lifecycle {
    create_before_destroy = true
  }
}

# Fetch the list of Availability Zones (AZs) for your account - good practice ??
data "aws_availability_zones" "all" {}

# ------------------------------------------------------------------------------
# Configure the Auto Scaling Group (ASG)
# ------------------------------------------------------------------------------
resource "aws_autoscaling_group" "autoscaling_group" {
  name = "${var.environment_name}-autoscaling-group"

  launch_configuration = "${aws_launch_configuration.launch_configuration.id}"

  # Availability Zones (AZs) the EC2 instances should be deployed
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  # A list of subnet IDs to launch resources in.
  vpc_zone_identifier = ["${var.public_subnet_ids}"]

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  # Register each EC2 instance in the ELB for the ELB to know which EC2 instances to send requests to
  load_balancers    = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${var.environment_name}-autoscaling-group", "propagate_at_launch", true),
      map("key", "Environment", "value", "${var.environment_name}", "propagate_at_launch", true)
    ))
  }"]
}

# ------------------------------------------------------------------------------
# Configure the EC2 security group
# ------------------------------------------------------------------------------
resource "aws_security_group" "ec2_security_group" {
  name = "${var.environment_name}-ec2-security-group"

  vpc_id = "${var.vpc_id}"

  # Allow the EC2 Instance to receive traffic on port server_port / 8080 from the CIDR block 0.0.0.0/0
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Setting this because of 'autoscaling_group' dependency on this resource
  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.environment_name}-ec2-security-group",
    Environment = "${var.environment_name}"
  }
}

# ------------------------------------------------------------------------------
# Configure the Elastic Load Balancer (ELB) configuration
# ------------------------------------------------------------------------------
resource "aws_elb" "elb" {
  name = "${var.environment_name}-elb"

  # The type of load balancer to create.
  #load_balancer_type = network

  # ELB security group
  security_groups = ["${aws_security_group.elb_security_group.id}"]

  # ELB that will work across all of the AZs in your account
  # availability_zones = ["${data.aws_availability_zones.all.names}"]
  # or
  # A list of subnet IDs to attach to the ELB
  subnets = ["${var.public_subnet_ids}"]

  # HTTP health check
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  tags {
    Name        = "${var.environment_name}-elb",
    Environment = "${var.environment_name}"
  }
}

# ------------------------------------------------------------------------------
# Configure the ELB security group
# ------------------------------------------------------------------------------
resource "aws_security_group" "elb_security_group" {
  name = "${var.environment_name}-elb-security-group"

  vpc_id = "${var.vpc_id}"

  # Receive HTTP requests on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # To allow outbound health check requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.environment_name}-elb-security-group",
    Environment = "${var.environment_name}"
  }
}
