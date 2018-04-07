# Server port EC2 insatnce should listen on
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}
