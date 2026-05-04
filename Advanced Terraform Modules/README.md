# Terraform Modules

This folder demonstrates how to organize Terraform code using reusable modules and separate live environments. The project builds an AWS web server cluster with an Auto Scaling Group, Application Load Balancer, security groups, and launch template.

The main goal is to avoid repeating infrastructure code across environments. The shared module defines the web server cluster once, while the `live` configurations reuse it with different settings for development and production.

## Project Structure

```text
Terraform Modules/
|-- live/
|   |-- dev/
|   |   `-- services/
|   |       `-- webserver-cluster/
|   |           |-- main.tf
|   |           |-- variables.tf
|   |           `-- .gitignore
|   `-- production/
|       `-- services/
|           `-- webserver-cluster/
|               |-- main.tf
|               |-- variables.tf
|               `-- .gitignore
|-- modules/
|   `-- services/
|       `-- webserver-cluster/
|           |-- main.tf
|           |-- variables.tf
|           |-- outputs.tf
|           `-- README.md
|-- screenshots/
`-- README.md
```

## Architecture

The reusable `webserver-cluster` module creates:

- An Amazon Linux EC2 launch template
- An Auto Scaling Group
- An Application Load Balancer
- A target group and listener
- Security groups for the load balancer and EC2 instances
- User data that starts a simple HTTP server on port `8080`

The live environments call this module and pass environment-specific values such as cluster name, instance type, and scaling limits.

## Environments

### Development

Path:

```bash
live/dev/services/webserver-cluster
```

Development uses:

- Cluster name: `webservers-dev`
- Instance type: `t2.micro`
- Minimum size: `2`
- Maximum size: `4`

### Production

Path:

```bash
live/production/services/webserver-cluster
```

Production uses:

- Cluster name: `webservers-production`
- Instance type: `t2.medium`
- Minimum size: `4`
- Maximum size: `10`

## VPC and Subnet Configuration

Both live environments are configured to use the default VPC and its subnets in `us-east-1` when no values are provided.

You can still override the network manually by passing `vpc_id` and `subnet_ids` through a `.tfvars` file or command-line variables.

Example `terraform.tfvars`:

```hcl
vpc_id = "vpc-0123456789abcdef0"

subnet_ids = [
  "subnet-0123456789abcdef0",
  "subnet-abcdef0123456789a"
]
```

## Prerequisites

Before running Terraform, make sure you have:

- Terraform installed
- An AWS account
- AWS credentials configured locally
- A default VPC in the target region, or explicit VPC/subnet IDs

The provider is configured to use:

```hcl
region = "us-east-1"
```

## Common Commands

Run commands from the environment directory you want to deploy.

For development:

```bash
cd live/dev/services/webserver-cluster
```

For production:

```bash
cd live/production/services/webserver-cluster
```

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt
```

Validate the configuration:

```bash
terraform validate
```

Preview the changes:

```bash
terraform plan
```

Apply the infrastructure:

```bash
terraform apply
```

Destroy the infrastructure when finished:

```bash
terraform destroy
```

## Module Inputs

The reusable module accepts the following inputs:

| Variable | Description | Type | Default |
| --- | --- | --- | --- |
| `cluster_name` | Name used for cluster resources | `string` | Required |
| `instance_type` | EC2 instance type | `string` | `t2.micro` |
| `vpc_id` | VPC ID where resources are deployed | `string` | Required |
| `subnet_ids` | Subnet IDs for the ALB and Auto Scaling Group | `list(string)` | Required |
| `min_size` | Minimum number of EC2 instances | `number` | Required |
| `max_size` | Maximum number of EC2 instances | `number` | Required |
| `server_port` | HTTP port used by the web server | `number` | `8080` |

## Module Outputs

The module exposes:

| Output | Description |
| --- | --- |
| `alb_dns_name` | DNS name of the Application Load Balancer |
| `asg_name` | Name of the Auto Scaling Group |

The development environment also exposes `alb_dns_name` so you can easily access the deployed application URL after running `terraform apply`.

## Notes

- The reusable module does not configure the AWS provider directly. Provider configuration belongs in the live environment roots.
- The `live` folders represent deployable Terraform root modules.
- The `modules` folder contains reusable infrastructure building blocks.
- The `.terraform` directory and state files should not be committed to version control.
- Production currently uses the same default VPC discovery pattern as development for learning convenience. In a real production setup, prefer explicitly managed networking.

## Screenshots

Screenshots for this exercise are stored in the `screenshots` folder.

Examples include:

- AWS Console output
- Development module output
- Production module output
