## Step-by-Step Guide to Setting Up Terraform, AWS CLI, and Your AWS Environment
Getting started with Terraform can feel overwhelming at first—especially when you also need to configure the AWS CLI and set up your cloud environment correctly.

In this guide, I’ll walk you through my exact setup process step by step, including the commands I used, the decisions I made, and a few issues I ran into along the way.

## Prerequisites
Before starting, make sure you have:
- An AWS account
- Basic knowledge of the terminal/command line
- Git installed (optional but recommended)

## Step 1: Install Terraform
I installed Terraform manually to have full control over the version.

## Download Terraform
Go to the official Terraform website and download the binary for your OS.
### Install (Windows)
1. Extract the `.zip` file
2. Move the `terraform.exe` file to a folder (e.g., `C:\terraform`)
3. Add that folder to your system **PATH**

## Verify Installation
```terraform -v```
If installed correctly, you should see the Terraform version printed.

## Step 2: Install AWS CLI
The AWS CLI allows Terraform to interact with your AWS account.
### Install (Windows)
Download and install AWS CLI v2 from the official AWS website.

## Verify Installation
```aws --version```

## Step 3: Create an IAM User for Terraform
Instead of using your root AWS account (which is unsafe), create an IAM user.

## Steps
1. Go to AWS Console
2. Navigate to **IAM → Users → Create User**
3. Enable **Programmatic Access**
4. Attach policy:
    -  For learning: `AdministratorAccess`
    - For production: use limited permissions
## Save Credentials
After creating the user, you’ll get:
- Access Key ID
- Secret Access Key
**Important:** Save these securely—you won’t be able to see the secret again.

## Step 4: Configure AWS CLI
Now connect your local machine to AWS:
```aws configure```
You’ll be prompted to enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name
- Default output format

## My Choices:
- Region: ```eu-east-1```
   - I chose this because it’s stable, widely used, and well-supported in tutorials
- Output format: ```json```

## Step 5: Test AWS CLI Connection
To confirm everything is working:
```aws sts get-caller-identity```
If successful, it returns your AWS account details.

## Step 6: Create Your First Terraform Project
Create a new folder:
```mkdir terraform-aws-setup```
```cd terraform-aws-setup```
Create a file called:
```main.tf```

## Step 7: Write Your First Terraform Configuration
Here’s a simple example to launch an EC2 instance:
```
provider "aws" {
  region = "eu-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Example AMI (may vary by region)
  instance_type = "t2.micro"
}
```
## Note:
AMI IDs are region-specific, so you may need to find the correct one for your region.

## Step 8: Initialize Terraform
```terraform init```
This downloads the AWS provider and prepares your project.

## Step 9: Preview the Changes
```terraform plan```
This shows what Terraform will create before making any changes.

## Step 10: Apply the Configuration
```terraform apply```
Type ```yes``` when prompted.
Terraform will now create your EC2 instance.

## Step 11: Clean Up Resources
To avoid unnecessary charges:
```terraform destroy```

## Final Thoughts

Setting up Terraform with AWS is the first major step into Infrastructure as Code.
Once this foundation is in place, you can:
- Automate entire cloud environments
- Build scalable systems
- Deploy infrastructure in minutes instead of hours
This setup might seem like a lot at first, but once it’s done—you rarely have to repeat it.