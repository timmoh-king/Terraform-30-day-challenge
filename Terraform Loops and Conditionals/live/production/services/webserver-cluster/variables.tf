variable "vpc_id" {
  description = "The VPC ID for the production webserver cluster."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "The subnet IDs for the production webserver cluster."
  type        = list(string)
  default     = []
}
