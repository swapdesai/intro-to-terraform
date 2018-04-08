# Server port EC2 insatnce should listen on
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

variable "min_size" {
  description = "The minimum number of EC2 instances in the ASG"
}

variable "max_size" {
  description = "The maximum number of EC2 instances in the ASG"
}

variable "vpc_id" {
  description = "The vpc id from module vpc"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "The public subnet ids from module vpc"
}
