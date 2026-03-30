# Terraform State Isolation

This project demonstrates how to isolate Terraform state across multiple environments using separate backend configurations. Each environment keeps its own remote state file in Amazon S3 while using a shared DynamoDB table for state locking. The setup helps prevent state collisions and makes infrastructure changes safer across `dev`, `staging`, and `production`.

## Project Overview

The Terraform code provisions an AWS EC2 instance for each environment. Although the resource definition is similar across environments, state is separated by backend key so each environment can be initialized, planned, and applied independently.

### What this project shows

- Remote state storage with an S3 backend
- State locking with DynamoDB
- Environment-specific state isolation
- A simple multi-environment Terraform folder structure
- Use of Terraform workspace naming inside resource tags

## Architecture

Each environment contains its own Terraform configuration files:

- `backend.tf` defines the remote backend location
- `main.tf` defines the EC2 instance resource
- `variables.tf` defines environment-based instance types
- `outputs.tf` is included for future outputs

State isolation is achieved through distinct backend keys:

- `environments/dev/terraform.tfstate`
- `environments/staging/terraform.tfstate`
- `environments/production/terraform.tfstate`

That means `dev`, `staging`, and `production` do not share the same state file even though their infrastructure code is very similar.

## Folder Structure

```text
Terraform State Isolation/
|-- README.md
|-- screenshots/
|-- terraform/
|   |-- environments/
|   |   |-- dev/
|   |   |   |-- backend.tf
|   |   |   |-- main.tf
|   |   |   |-- variables.tf
|   |   |   `-- outputs.tf
|   |   |-- staging/
|   |   |   |-- backend.tf
|   |   |   |-- main.tf
|   |   |   |-- variables.tf
|   |   |   `-- outputs.tf
|   |   `-- production/
|   |       |-- backend.tf
|   |       |-- main.tf
|   |       |-- variables.tf
|   |       `-- outputs.tf
|   `-- .gitignore
```

## Backend Configuration

Each environment uses the same S3 bucket and DynamoDB lock table, but a different state file path.

Example:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-unique-project-name-2026-v1"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

## Resource Configuration

The project creates an EC2 instance using the AWS provider resource type `aws_instance`. Instance size is selected from a map based on the active Terraform workspace name:

- `dev` -> `t2.micro`
- `staging` -> `t2.small`
- `production` -> `t2.medium`

Resources are tagged with:

- `Name = web-<workspace>`
- `Environment = <workspace>`

## Prerequisites

Before using this project, make sure you have:

- Terraform installed
- AWS credentials configured
- An existing S3 bucket for remote state
- An existing DynamoDB table for Terraform locking
- Access to the AWS region configured in the backend

## How to Use

Terraform must be run from an environment directory because the top-level `terraform/` folder does not contain `.tf` configuration files.

### Initialize an environment

```bash
cd terraform/environments/dev
terraform init
```

You can do the same for other environments:

```bash
cd terraform/environments/staging
terraform init
```

```bash
cd terraform/environments/production
terraform init
```

### Create or select a workspace

```bash
terraform workspace new dev
terraform workspace select dev
```

For staging and production:

```bash
terraform workspace new staging
terraform workspace select staging
```

```bash
terraform workspace new production
terraform workspace select production
```

### Preview changes

```bash
terraform plan
```

### Apply infrastructure

```bash
terraform apply
```

### Destroy infrastructure

```bash
terraform destroy
```

## Why State Isolation Matters

Terraform state isolation is important because it:

- Prevents one environment from overwriting another
- Reduces the risk of accidental production changes
- Makes troubleshooting easier
- Supports safer team collaboration
- Improves separation of lifecycle and deployment workflows

## Current Notes

- The `outputs.tf` files are present but currently empty
- The same EC2 resource pattern is repeated across environments
- The backend bucket and DynamoDB table must exist before `terraform init`

## Screenshots

The `screenshots/` folder includes images that can be used to document setup and results:

- `banner image.png`
- `ec2.png`
- `s3.png`
- `terraform environment.png`
- `workspace list.png`

## Future Improvements

- Add explicit provider and version constraints
- Add useful Terraform outputs
- Refactor shared logic into reusable modules
- Parameterize AMI IDs by region or environment
- Add CI/CD validation for `terraform fmt`, `validate`, and `plan`

## Summary

This project is a clean example of using Terraform to manage isolated infrastructure environments with remote state. By separating backend state per environment, it becomes easier to manage infrastructure safely, scale workflows, and maintain clear boundaries between development, staging, and production.
