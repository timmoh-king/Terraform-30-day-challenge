# Basic Terraform Infrastructure

This project provisions a simple, highly available web infrastructure on AWS using Terraform. It launches Amazon Linux 2 EC2 instances behind an Application Load Balancer (ALB) and manages them with an Auto Scaling Group (ASG).

The deployed instances install Apache HTTP Server during boot and serve a basic landing page. The setup is designed as a beginner-friendly Terraform project for learning core AWS infrastructure provisioning concepts.

## What This Project Creates

- An AWS provider configuration using a selected region
- The default VPC and its subnets
- A security group allowing:
  - HTTP traffic on port `80`
  - SSH access on port `22`
- A launch template for EC2 instances
- An Application Load Balancer
- A target group and listener for routing HTTP traffic
- An Auto Scaling Group for managing multiple EC2 instances

## Architecture Overview

The infrastructure uses the default AWS networking environment in the selected region. Terraform discovers the default VPC and subnets automatically, then deploys a load-balanced web tier across those subnets.

Flow:

1. A user sends a request to the ALB.
2. The ALB forwards traffic to the target group.
3. The target group routes traffic to EC2 instances created by the Auto Scaling Group.
4. Each EC2 instance installs Apache and serves a simple HTML page.

## Project Structure

```text
Basic Terraform Infra/
|-- README.md
`-- terraform/
    |-- main.tf
    |-- variables.tf
    |-- outputs.tf
    `-- .gitignore
```

## Terraform Files

### `main.tf`
Defines the core AWS infrastructure:

- AWS provider
- Data sources for availability zones, default VPC, subnets, and Amazon Linux 2 AMI
- Security group
- Launch template
- Application Load Balancer
- Target group and listener
- Auto Scaling Group

### `variables.tf`
Defines configurable inputs such as:

- AWS region
- EC2 instance type
- Web server port
- SSH port
- Auto Scaling Group size settings
- Project name prefix

### `outputs.tf`
Exports the ALB DNS name so you can access the deployed application after `terraform apply`.

## Prerequisites

Before running this project, make sure you have:

- [Terraform](https://developer.hashicorp.com/terraform/downloads) installed
- An AWS account
- AWS credentials configured locally using one of the following:
  - AWS CLI credentials
  - Environment variables
  - Named AWS profile

## Usage

From the `terraform` folder:

```bash
terraform init
terraform plan
terraform apply
```

After deployment, Terraform will output the ALB DNS name:

```bash
terraform output alb_dns_name
```

Open that DNS name in your browser to view the web page served by the EC2 instances.

## Input Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-east-1` |
| `instance_type` | EC2 instance type | `t2.micro` |
| `server_port` | Port used by the web server and ALB listener | `80` |
| `ssh_port` | Port used for SSH access | `22` |
| `min_size` | Minimum number of EC2 instances | `2` |
| `max_size` | Maximum number of EC2 instances | `5` |
| `desired_capacity` | Desired number of EC2 instances | `2` |
| `project_name` | Prefix used in naming resources | `terraform-web` |

## Output

| Output | Description |
|--------|-------------|
| `alb_dns_name` | Public DNS name of the Application Load Balancer |

## Notes

- This project uses the **default VPC** and **default subnets** in your AWS account.
- The web page is created through EC2 `user_data` during instance launch.
- The security group currently allows public access to both HTTP and SSH. For production use, SSH access should be restricted to trusted IP addresses only.

## Cleanup

To remove all created infrastructure:

```bash
terraform destroy
```

## Learning Goals

This project is useful for practicing:

- Terraform basics
- AWS provider configuration
- Terraform data sources
- EC2 launch templates
- Application Load Balancer setup
- Auto Scaling Group deployment
- Infrastructure outputs and reusable variables
