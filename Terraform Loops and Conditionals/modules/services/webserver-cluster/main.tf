locals {
  instance_type = var.instance_type != null ? var.instance_type : var.environment == "production" ? "t2.medium" : "t2.micro"

  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


# -------------------------
# Security Group for ALB
# -------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${var.cluster_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = locals.common_tags
}

resource "aws_security_group_rule" "alb_ingress" {
  for_each = var.ingress_ports

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

# -------------------------
# Security Group for EC2
# -------------------------
resource "aws_security_group" "instance_sg" {
  name   = "${var.cluster_name}-instance-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.server_port
    to_port         = var.server_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# Launch Template
# -------------------------
resource "aws_launch_template" "example" {
  name_prefix   = "${var.cluster_name}-"
  image_id      = data.aws_ami.amazon_linux.id # update per region
  instance_type = local.instance_type

  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  )
}

# -------------------------
# Target Group
# -------------------------
resource "aws_lb_target_group" "example" {
  name     = "${var.cluster_name}-tg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# -------------------------
# Load Balancer (ALB)
# -------------------------
resource "aws_lb" "example" {
  name               = "${var.cluster_name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnet_ids
}

# -------------------------
# Listener
# -------------------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.server_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# -------------------------
# Auto Scaling Group
# -------------------------
resource "aws_autoscaling_group" "example" {
  name                = "${var.cluster_name}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.min_size
  vpc_zone_identifier = var.subnet_ids

  launch_template {
    id      = aws_launch_template.example.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.example.arn]

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = var.cluster_name
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  count = var.enable_autoscaling ? 1 : 0

  name                   = "${var.cluster_name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.example.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}
