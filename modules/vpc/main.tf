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
# Configure a VPC
# ------------------------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/18"

  tags {
    Name        = "${var.environment_name}-vpc"
    Environment = "${var.environment_name}"
  }
}

# Create a VPC internet gateway
resource "aws_internet_gateway" "internet_gateway" {
	vpc_id = "${aws_vpc.vpc.id}"

	tags {
    Name        = "${var.environment_name}-internet-gateway"
    Environment = "${var.environment_name}"
  }
}

# Public subnet 2a
resource "aws_subnet" "public-a" {
  vpc_id = "${aws_vpc.vpc.id}"

  cidr_block       = "10.0.0.0/24"
  availability_zone = "ap-southeast-2a"

  tags {
    Name        = "${var.environment_name}-public-a"
    Environment = "${var.environment_name}"
  }
}

# Public subnet 2a
resource "aws_subnet" "public-b" {
  vpc_id = "${aws_vpc.vpc.id}"

  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-2b"

  tags {
    Name        = "${var.environment_name}-public-b"
    Environment = "${var.environment_name}"
  }
}

# Public subnet 2c
resource "aws_subnet" "public-c" {
  vpc_id = "${aws_vpc.vpc.id}"

  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-2c"

  tags {
    Name        = "${var.environment_name}-public-c"
    Environment = "${var.environment_name}"
  }
}

# Routing table for public subnets
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.internet_gateway.id}"
	}

	tags {
    Name        = "${var.environment_name}-public"
    Environment = "${var.environment_name}"
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
