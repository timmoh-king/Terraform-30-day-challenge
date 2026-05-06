# Webserver Cluster Module

This module deploys a simple HTTP web server cluster on AWS using an Auto Scaling Group behind an Application Load Balancer. It creates security groups for the load balancer and instances, a launch template using the latest Amazon Linux 2 AMI, an ALB target group and listener, and an Auto Scaling Group that serves a basic "Hello, World" page on the configured server port.

## Inputs

| Name | Type | Description | Default |
| --- | --- | --- | --- |
| `cluster_name` | `string` | The name to use for all cluster resources. | n/a |
| `instance_type` | `string` | EC2 instance type for the cluster. | `"t2.micro"` |
| `vpc_id` | `string` | The VPC ID where the webserver cluster will be deployed. | n/a |
| `subnet_ids` | `list(string)` | The subnet IDs where the ALB and Auto Scaling Group will be deployed. | n/a |
| `min_size` | `number` | Minimum number of EC2 instances in the ASG. | n/a |
| `max_size` | `number` | Maximum number of EC2 instances in the ASG. | n/a |
| `server_port` | `number` | Port the server uses for HTTP. | `8080` |

## Outputs

| Name | Description |
| --- | --- |
| `alb_dns_name` | The domain name of the load balancer - visible after creation. |
| `asg_name` | The name of the Auto Scaling Group - visible after creation. |

## Usage

```hcl
module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-dev"
  vpc_id       = "vpc-1234567890abcdef0"
  subnet_ids   = ["subnet-1234567890abcdef0", "subnet-abcdef1234567890"]
  min_size     = 2
  max_size     = 4
}
```

## Limitations and Gotchas

- The module uses the latest Amazon Linux 2 AMI owned by Amazon for the selected AWS region.
- The launch template starts a very simple BusyBox HTTP server that serves a static "Hello, World" page; this module is for learning/demo workloads, not production application deployment.
- The ALB listener and instance security group both use `server_port`, which defaults to `8080`. If you expect standard HTTP traffic on port `80`, set `server_port = 80`.
- The ALB security group allows inbound traffic from `0.0.0.0/0` on `server_port`.
- `desired_capacity` is set to `min_size`, so the cluster starts with the minimum number of instances.
- The target group name includes `cluster_name` and must fit AWS target group naming limits.
