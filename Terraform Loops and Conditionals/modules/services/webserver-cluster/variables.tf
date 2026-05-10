variable "cluster_name" {
  description = "The name to use for all cluster resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type override"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The VPC ID where the webserver cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs where the ALB and ASG will be deployed"
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

variable "enable_autoscaling" {
  description = "Enable autoscaling policies"
  type        = bool
  default     = true
}

variable "ingress_ports" {
  description = "Ports allowed into the ALB"
  type        = set(number)
  default     = [80, 443]
}