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

# Pull VPC date from remote storage
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket = "intro-to-terraform-remote-state-storage"
    key    = "stage/vpc/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

module "frontend" {
  source = "../../../modules/frontend-app"

  min_size = 1
  max_size = 2

  vpc_id            = "${data.terraform_remote_state.vpc.vpc_id}"
  public_subnet_ids = "${data.terraform_remote_state.vpc.public_subnet_ids}"
}

# Get DNS name of the ELB
output "elb_dns_name" {
  value = "${module.frontend.elb_dns_name}"
}
