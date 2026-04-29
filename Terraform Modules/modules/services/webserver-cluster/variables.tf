variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the cluster"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "The VPC ID where the webserver cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs where the ALB and Auto Scaling Group will be deployed"
  type        = list(string)
}

variable "min_size" {
  description = "Minimum number of EC2 instances in the ASG"
  type        = number
}

variable "max_size" {
  description = "Maximum number of EC2 instances in the ASG"
  type        = number
}

variable "server_port" {
  description = "Port the server uses for HTTP"
  type        = number
  default     = 8080
}
