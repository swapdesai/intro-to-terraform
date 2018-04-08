# ------------------------------------------------------------------------------
# Configure the AWS S3 as remote backend including locking and consistency
# ------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "intro-to-terraform-remote-state-storage"
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-2"

    # (Optional) The name of a DynamoDB table to use for state locking and consistency.
    # The table must have a primary key named LockID. If not present, locking will be disabled.
    # dynamodb_table = <<dynamodb_table>>
  }
}

variable "environment_name" {
  default = "prod"
}

# ------------------------------------------------------------------------------
# Execute VPC module
# ------------------------------------------------------------------------------
module "vpc" {
  source = "../../modules/vpc"

  environment_name = "${var.environment_name}"
}

# ------------------------------------------------------------------------------
# OUTPUTS - Any module outputs need to be explicitly exposed.
# ------------------------------------------------------------------------------
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "public_subnet_ids" {
  value = "${module.vpc.public_subnet_ids}"
}
