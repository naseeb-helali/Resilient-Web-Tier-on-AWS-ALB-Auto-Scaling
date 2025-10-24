variable "project" {
  description = "A short, unique project prefix for resource names"
  type        = string
  default     = "elb-asg-blueprint"
}

variable "region" {
  description = "AWS region (for plan-only you can keep any value)"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "Existing VPC ID (Phase-1 assumes pre-existing networking)"
  type        = string
}

variable "public_subnet_ids" {
  description = "Two or more public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Two or more private subnet IDs for ASG"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID used by the launch template (any Linux AMI for plan-only)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN (leave empty to skip HTTPS listener)"
  type        = string
  default     = ""
}

variable "default_tags" {
  description = "Default resource tags"
  type        = map(string)
  default = {
    Project = "elb-asg-blueprint"
    Owner   = "naseeb"
    TTL     = "1h"
    Env     = "dev"
  }
}
