# Example: Using the VPC and Web App modules together

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

# VPC Module
module "networking" {
  source = "../../modules/networking"
  
  environment        = var.environment
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# Web Application Module
module "web_app" {
  source = "../../modules/web-app"
  
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  subnet_ids       = module.networking.public_subnet_ids
  instance_type    = "t3.small"
  min_size         = 3
  max_size         = 10
  desired_capacity = 3
}

# Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.web_app.load_balancer_dns
}

output "nat_gateway_ips" {
  description = "NAT Gateway IPs"
  value       = module.networking.nat_gateway_ips
}
