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
# Configure the AWS S3 as remote backend including locking and consistency
# ------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "intro-to-terraform-remote-state-storage"
    key    = "stage/services/frontend-app/terraform.tfstate"
    region = "ap-southeast-2"

    # (Optional) The name of a DynamoDB table to use for state locking and consistency.
    # The table must have a primary key named LockID. If not present, locking will be disabled.
    # dynamodb_table = <<dynamodb_table>>
  }
}

# ------------------------------------------------------------------------------
# Configure the AWS launch configuration
# ------------------------------------------------------------------------------
resource "aws_launch_configuration" "example" {
  image_id        = "ami-d38a4ab1"
  instance_type   = "t2.micro"

  # Security group to be used by the EC2 instance
  # Use interpolation feature of Terraform - syntax is “${TYPE.NAME.ATTRIBUTE}”
  security_groups = ["${aws_security_group.instance.id}"]

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

# Fetch the list of Availability Zones (AZs) for your account
data "aws_availability_zones" "all" {}

# ------------------------------------------------------------------------------
# Configure the Auto Scaling Group (ASG)
# ------------------------------------------------------------------------------
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"

  # Availability Zones (AZs) the EC2 instances should be deployed
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  min_size = 2
  max_size = 10

  # Register each EC2 instance in the ELB for the ELB to know which EC2 instances to send requests to
  load_balancers    = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"

    # Enables propagation of the tag to Amazon EC2 instances launched via this ASG
    propagate_at_launch = true
  }
}

# ------------------------------------------------------------------------------
# Configure the EC2 security group
# ------------------------------------------------------------------------------
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # Allow the EC2 Instance to receive traffic on port server_port / 8080 from the CIDR block 0.0.0.0/0
  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Setting this because of 'aws_autoscaling_group' dependency on this resource
  lifecycle {
    create_before_destroy = true
  }
}

# Pull VPC date from remote storage
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "intro-to-terraform-remote-state-storage"
    key    = "stage/vpc/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

# ------------------------------------------------------------------------------
# Configure the Elastic Load Balancer (ELB) configuration
# ------------------------------------------------------------------------------
resource "aws_elb" "example" {
  name = "terraform-asg-example"

  # ELB security group
  security_groups = ["${aws_security_group.elb.id}"]

  # ELB that will work across all of the AZs in your account
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  # A list of subnet IDs to attach to the ELB
  subnets = ["${data.terraform_remote_state.vpc.public_subnet_ids}"]

  # HTTP health check
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  listener {
    lb_port          = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }
}

# ------------------------------------------------------------------------------
# Configure the ELB security group
# ------------------------------------------------------------------------------
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  # Receive HTTP requests on port 80
  ingress {
    from_port  = 80
    to_port    = 80
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
}
