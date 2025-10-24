terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------------------------
# Security Groups
# ---------------------------
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "Allow HTTP/HTTPS from the internet"
  vpc_id      = var.vpc_id

  # HTTP (for redirect or plan-only)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS (enabled in production when ACM is provided)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.project}-alb-sg" })
}

resource "aws_security_group" "asg_sg" {
  name        = "${var.project}-asg-sg"
  description = "Allow HTTP only from ALB SG"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.project}-asg-sg" })
}

# ---------------------------
# Load Balancer + Target Group
# ---------------------------
resource "aws_lb" "app_alb" {
  name                       = "${var.project}-alb"
  load_balancer_type         = "application"
  subnets                    = var.public_subnet_ids
  security_groups            = [aws_security_group.alb_sg.id]
  enable_deletion_protection = false
  idle_timeout               = 60
  tags                       = merge(var.default_tags, { Name = "${var.project}-alb" })
}

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  deregistration_delay = 300
  tags                 = merge(var.default_tags, { Name = "${var.project}-tg" })
}

# HTTP listener (always present)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = var.acm_certificate_arn == "" ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app_tg.arn
    }
  }

  dynamic "default_action" {
    for_each = var.acm_certificate_arn != "" ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

# HTTPS listener (created only when ACM ARN is provided)
resource "aws_lb_listener" "https" {
  count             = var.acm_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ---------------------------
# Launch Template + Auto Scaling Group
# ---------------------------
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = filebase64("${path.module}/user_data/bootstrap.sh")

  network_interfaces {
    security_groups = [aws_security_group.asg_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.default_tags, { Name = "${var.project}-node" })
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project}-asg"
  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 4
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  # Termination policy biased to AZ balance and oldest first
  termination_policies = ["OldestInstance", "ClosestToNextInstanceHour"]

  # Lifecycle hooks
  lifecycle_hook {
    name                 = "bootstrap-wait"
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }

  lifecycle_hook {
    name                 = "drain-logs"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 300
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-node"
    propagate_at_launch = true
  }

  tags = []
}
