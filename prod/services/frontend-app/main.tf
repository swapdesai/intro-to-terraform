# ------------------------------------------------------------------------------
# Configure the AWS S3 as remote backend including locking and consistency
# ------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "intro-to-terraform-remote-state-storage"
    key    = "prod/services/frontend-app/terraform.tfstate"
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
    key    = "prod/vpc/terraform.tfstate"
    region = "ap-southeast-2"
  }
}

variable "environment_name" {
  default = "prod"
}

# ------------------------------------------------------------------------------
# Execute frontend module
# ------------------------------------------------------------------------------
module "frontend" {
  source = "../../../modules/frontend-app"

  environment_name = "${var.environment_name}"
  
  min_size = 2
  max_size = 5

  vpc_id            = "${data.terraform_remote_state.vpc.vpc_id}"
  public_subnet_ids = "${data.terraform_remote_state.vpc.public_subnet_ids}"
}

# Adding Auto Scaling policy to prod env
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out-frontend-app"
  autoscaling_group_name = "${module.frontend.asg_name}"

  adjustment_type    = "ChangeInCapacity"
  policy_type        = "SimpleScaling"
  scaling_adjustment = 1
  cooldown           = 200
}

# Get DNS name of the ELB
output "elb_dns_name" {
  value = "${module.frontend.elb_dns_name}"
}
