variable "vpc_id" {
  description = "The VPC ID for the dev webserver cluster."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "The subnet IDs for the dev webserver cluster."
  type        = list(string)
  default     = []
}
