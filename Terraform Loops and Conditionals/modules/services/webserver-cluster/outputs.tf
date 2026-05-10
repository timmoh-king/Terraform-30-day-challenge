output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}

output "asg_name" {
  value       = aws_autoscaling_group.example.name
  description = "The Auto Scaling Group name"
}

output "subnet_map" {
  description = "Map of subnet indexes to subnet IDs"

  value = {
    for index, subnet in var.subnet_ids :
    index => subnet
  }
}

output "security_group_ids" {
  description = "Map of security groups"

  value = {
    alb_sg      = aws_security_group.alb_sg.id
    instance_sg = aws_security_group.instance_sg.id
  }
}