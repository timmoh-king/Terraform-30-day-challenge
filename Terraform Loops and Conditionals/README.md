# Terraform Loops and Conditionals

This folder demonstrates advanced Terraform patterns for using **loops** and **conditionals** to create flexible, reusable infrastructure code. These techniques allow you to write more concise and maintainable configurations by avoiding repetition and enabling dynamic resource creation.

## Overview

This project implements a scalable webserver cluster on AWS using a modular approach that showcases:

- **Loops**: Using `for_each` and `for` expressions to iterate over collections
- **Conditionals**: Using `count`, ternary operators, and conditional logic for dynamic resource creation
- **Locals**: Combining loops and conditionals in local values for cleaner code

## Project Structure

```
├── live/                          # Environment-specific configurations
│   ├── dev/                       # Development environment
│   └── production/                # Production environment
│       └── services/
│           └── webserver-cluster/
│               └── main.tf        # Environment-specific module usage
│
├── modules/                       # Reusable infrastructure modules
│   └── services/
│       └── webserver-cluster/
│           ├── main.tf           # Core module with loops and conditionals
│           ├── variables.tf       # Input variables
│           ├── outputs.tf         # Output values
│           └── README.md          # Module documentation
```

## Key Concepts

### 1. Loops with `for_each`

The `for_each` meta-argument creates multiple resource instances from a collection:

```hcl
resource "aws_security_group_rule" "alb_ingress" {
  for_each = var.ingress_ports

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}
```

**Benefits:**
- Creates a separate resource for each port in `ingress_ports`
- Uses `each.key` and `each.value` to access collection items
- Easier to manage individual resources compared to `count`
- Better modularity and state management

**Usage:** Ideal for collections like maps or sets where you need unique keys for resource identification.

### 2. Loops with `for` Expressions

The `for` expression (different from `for_each`) transforms collections into new structures:

```hcl
output "subnet_map" {
  description = "Map of subnet indexes to subnet IDs"

  value = {
    for index, subnet in var.subnet_ids :
    index => subnet
  }
}
```

**Benefits:**
- Transforms lists into maps or other structures
- Available in outputs, locals, and string interpolations
- Enables complex data transformations

**Usage:** Perfect for aggregating data, creating lookup tables, or restructuring outputs.

### 3. Conditionals with `count`

The `count` meta-argument conditionally creates resources based on boolean logic:

```hcl
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0

  name                   = "${var.cluster_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}
```

**Benefits:**
- Conditionally create or destroy resources based on input variables
- Syntax: `count = condition ? 1 : 0` (creates 1 instance if true, 0 if false)
- Access created resources with `resource_type.name[0]`

**Usage:** Useful for optional features, environment-specific resources, or feature flags.

### 4. Conditionals with Ternary Operators

Inline conditional logic for selecting values dynamically:

```hcl
locals {
  instance_type = var.instance_type != null ? var.instance_type : var.environment == "production" ? "t2.medium" : "t2.micro"
}
```

**Features:**
- **Nested ternary operators** for complex decision trees
- Select between different values based on conditions
- Cleaner than if-else constructs
- Syntax: `condition ? value_if_true : value_if_false`

**In this example:**
1. First checks if `instance_type` was explicitly provided
2. If not, checks if environment is "production"
3. Uses "t2.medium" for production, "t2.micro" for dev

### 5. Combining with `coalesce()`

The `coalesce()` function selects the first non-null/non-empty value:

```hcl
vpc_id = coalesce(var.vpc_id, data.aws_vpc.default.id)
```

**Benefits:**
- Provides fallback values
- Cleaner than nested ternary operators for multiple options
- Returns first non-null argument

## Module Features

### Security Groups with Dynamic Ingress Rules

The module creates security groups with dynamically configured ingress ports:

```hcl
variable "ingress_ports" {
  description = "Ports allowed into the ALB"
  type        = set(number)
  default     = [80, 443]
}
```

Each port becomes a separate security group rule created via `for_each`.

### Environment-Based Configuration

The module adapts based on the environment variable:

- **Development**: Uses `t2.micro` instances, no autoscaling by default
- **Production**: Uses `t2.medium` instances, autoscaling enabled by default

### Conditional Autoscaling Policies

Autoscaling policies are only created when `enable_autoscaling = true`:

```hcl
resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0
  # ...
}
```

## Input Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `cluster_name` | string | Name for all cluster resources | *required* |
| `environment` | string | Deployment environment (dev/production) | "dev" |
| `instance_type` | string | EC2 instance type override | null |
| `vpc_id` | string | VPC ID for deployment | *required* |
| `subnet_ids` | list(string) | Subnets for ALB and ASG | *required* |
| `min_size` | number | Minimum EC2 instances | *required* |
| `max_size` | number | Maximum EC2 instances | *required* |
| `server_port` | number | Port for HTTP server | 8080 |
| `enable_autoscaling` | bool | Enable autoscaling policies | true |
| `ingress_ports` | set(number) | ALB ingress ports | [80, 443] |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | The domain name of the load balancer |
| `asg_name` | The Auto Scaling Group name |
| `subnet_map` | Map of subnet indexes to subnet IDs |
| `security_group_ids` | Map of ALB and instance security group IDs |

## Usage Example

### Development Environment

```hcl
module "webserver_cluster" {
  source = "./modules/services/webserver-cluster"

  cluster_name       = "webservers-dev"
  environment        = "dev"
  min_size           = 2
  max_size           = 4
  enable_autoscaling = false  # Disable autoscaling in dev

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
}
```

### Production Environment

```hcl
module "webserver_cluster" {
  source = "./modules/services/webserver-cluster"

  cluster_name       = "webservers-prod"
  environment        = "production"
  min_size           = 4
  max_size           = 10
  enable_autoscaling = true  # Enable autoscaling in production

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.main[*].id
}
```

## Best Practices Demonstrated

### 1. Use `for_each` Over `count` When Possible
- `for_each` provides stable resource addressing with string keys
- `count` is better for simple true/false conditionals
- Avoid mixing them to prevent state inconsistencies

### 2. Use Locals for Complex Logic
```hcl
locals {
  instance_type = var.instance_type != null ? var.instance_type : var.environment == "production" ? "t2.medium" : "t2.micro"
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
```
- Extract complex conditional logic into locals for readability
- Reuse computed values throughout the module

### 3. Combine Loops and Conditionals Strategically
- Use `for_each` + locals to create complex resource configurations
- Use `count` for optional resources with clear on/off logic
- Use `for` expressions to transform and aggregate data

### 4. Document Dynamic Behavior
- Clearly explain in variables which parameters control dynamic behavior
- Use default values that match typical use cases
- Provide examples for different scenarios

### 5. Make Modules Flexible
- Accept sets/lists for dynamic iteration
- Provide boolean flags for optional features
- Use null coalescing for reasonable defaults

## Prerequisites

- AWS account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured with credentials

## Deployment

1. **Review the module**: `cat modules/services/webserver-cluster/main.tf`

2. **Deploy to development environment**:
   ```bash
   cd live/dev/services/webserver-cluster
   terraform init
   terraform plan
   terraform apply
   ```

3. **Deploy to production environment**:
   ```bash
   cd live/production/services/webserver-cluster
   terraform init
   terraform plan
   terraform apply
   ```

## Common Patterns

### Dynamic List Processing
```hcl
# Flatten a list of objects
availability_zones = flatten([
  for subnet in var.subnets :
  [for az in subnet.azs : az]
])
```

### Conditional Resource Naming
```hcl
name = "${var.environment}-${var.cluster_name}${var.enable_cache ? "-cached" : ""}"
```

### Map Filtering with For
```hcl
# Only include tagged resources
tagged_resources = {
  for key, resource in aws_instance.servers :
  key => resource if resource.tags["Monitored"] == true
}
```

## Troubleshooting

**Issue: Resources not created with `count = var.enable_autoscaling ? 1 : 0`**
- Verify the variable value is actually `true`
- Check that `enable_autoscaling` is being passed to the module

**Issue: `for_each` key conflicts**
- Ensure the collection keys are unique and stable
- Avoid using computed values that change frequently

**Issue: Ternary operator getting complex**
- Extract logic into locals for better readability
- Consider using `try()` for safer value selection

## Key Takeaways

1. **Loops reduce repetition**: `for_each` and `for` expressions eliminate boilerplate code
2. **Conditionals add flexibility**: `count` and ternary operators enable dynamic configurations
3. **Locals improve readability**: Complex logic should be extracted to locals
4. **Combine them strategically**: Use loops to iterate and conditionals to customize behavior
5. **Modules amplify benefits**: These patterns shine when building reusable infrastructure modules

## References

- [Terraform `for_each` Documentation](https://www.terraform.io/language/meta-arguments/for_each)
- [Terraform `count` Documentation](https://www.terraform.io/language/meta-arguments/count)
- [Terraform `for` Expressions](https://www.terraform.io/language/expressions/for)
- [Terraform Conditionals](https://www.terraform.io/language/expressions/conditionals)
