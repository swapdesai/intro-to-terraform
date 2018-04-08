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

module "frontend" {
  source = "../../../modules/frontend-app"

  min_size = 5
  max_size = 20
}

# Adding Auto Scalign policy to prod env
resource "aws_autoscaling_policy" "scale_out" {
  name = "scale-out-frontend-app"
  autoscaling_group_name = "${module.frontend.asg_name}"
  adjustment_type = "ChangeInCapacity"
  policy_type = "SimpleScaling"
  scaling_adjustment = 1
  cooldown = 200
}
