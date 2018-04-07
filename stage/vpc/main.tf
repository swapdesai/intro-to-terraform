# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This template creates a VPC and public subnets
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
    key    = "stage/vpc/terraform.tfstate"
    region = "ap-southeast-2"

    # (Optional) The name of a DynamoDB table to use for state locking and consistency.
    # The table must have a primary key named LockID. If not present, locking will be disabled.
    # dynamodb_table = <<dynamodb_table>>
  }
}

# ------------------------------------------------------------------------------
# Configure a VPC
# ------------------------------------------------------------------------------
resource "aws_vpc" "stage" {
  cidr_block = "10.0.0.0/18"

  tags {
    Name = "stage"
  }
}

# Create a VPC internet gateway
resource "aws_internet_gateway" "stage" {
	vpc_id = "${aws_vpc.stage.id}"

	tags {
    Name = "stage"
  }
}

# Public subnet 2a
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block       = "10.0.0.0/24"
  availability_zone = "ap-southeast-2a"

  tags {
    Name = "public-a"
  }
}

# Public subnet 2a
resource "aws_subnet" "public-b" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2b"

  tags {
    Name = "public-b"
  }
}

# Public subnet 2c
resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.stage.id}"

  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2c"

  tags {
    Name = "public-c"
  }
}

# Routing table for public subnets
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.stage.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.stage.id}"
	}

	tags {
    Name = "public"
  }
}

# Routing table association for public subnets
resource "aws_route_table_association" "public-a" {
	subnet_id      = "${aws_subnet.public-a.id}"
	route_table_id = "${aws_route_table.public.id}"
}

# Routing table association for public subnets
resource "aws_route_table_association" "public-b" {
	subnet_id      = "${aws_subnet.public-b.id}"
	route_table_id = "${aws_route_table.public.id}"
}

# Routing table association for public subnets
resource "aws_route_table_association" "public-c" {
	subnet_id      = "${aws_subnet.public-c.id}"
	route_table_id = "${aws_route_table.public.id}"
}
