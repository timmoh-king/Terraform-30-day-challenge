# Introduction to IaC (Terraform Demo)

##  Project Overview
This repository contains an AWS networking demo built with Terraform. It deploys a VPC with:
- One VPC
- 3 public subnets
- 3 private subnets
- Internet Gateway
- NAT Gateway + Elastic IP
- Public and private route tables and associations

##  Repository Structure
- `terraform/main.tf`: Terraform resources (VPC, subnets, IGW, NAT, route tables)
- `terraform/variables.tf`: Input variables for CIDR and subnet mapping
- `terraform/terraform.tfstate`: Terraform state file (generated after apply)
- `terraform/.terraform/`: Terraform provider cache
- `screenshots/`: Project screenshots (architecture and output)

##  Architecture Summary
This module creates a multi-AZ private/public networking setup:
1. Reads available AZ names in region
2. Creates VPC with CIDR `10.0.0.0/16`
3. Builds public and private subnets across 3 AZs
4. Creates an Internet Gateway and attaches it to VPC
5. Creates a NAT Gateway in one public subnet
6. Creates and associates route tables:
   - Public route table with IGW route
   - Private route table with NAT gateway route

##  Prerequisites
1. Install Terraform (v1.5+ recommended)
2. Install AWS CLI
3. Configure AWS credentials:
   ```powershell
   aws configure
   ```
4. (Optional) Verify access:
   ```powershell
   aws sts get-caller-identity
   ```

##  Run this demo
Open terminal in `terraform/` and run:
```powershell
terraform init
terraform validate
terraform plan -out plan.tfplan
terraform apply "plan.tfplan"
```

##  Tear down
```powershell
terraform destroy
```

##  Variables (from `terraform/variables.tf`)
- `aws_region` (default `us-east-1`)
- `vpc_name` (default `demo_vpc`)
- `vpc_cidr` (default `10.0.0.0/16`)
- `private_subnets` (mapped AZ indexes 1-3)
- `public_subnets` (mapped AZ indexes 1-3)

##  Screenshots
Open `screenshots/` to review architecture and output screenshots for this exercise.

##  Notes
- NAT Gateway is deployed in `public_subnet_1`.
- `cidrsubnet(var.vpc_cidr, 8, each.value)` is used to derive subnet CIDRs.
- This is a demo learning lab for Terraform AWS networking.
