---
description: Infrastructure as Code workflow using Terraform and CloudFormation
---

# Infrastructure as Code (IaC)

Manage infrastructure through code with version control, automation, and best practices.

## Overview

Infrastructure as Code allows you to define, provision, and manage infrastructure using declarative configuration files instead of manual processes.

## Usage

```powershell
# Initialize IaC project
.agent\scripts\Manage-IaC.ps1 -Action "init" -Provider "terraform"

# Validate configuration
.agent\scripts\Manage-IaC.ps1 -Action "validate"

# Plan changes
.agent\scripts\Manage-IaC.ps1 -Action "plan"

# Apply infrastructure
.agent\scripts\Manage-IaC.ps1 -Action "apply" -Environment "staging"

# Destroy infrastructure
.agent\scripts\Manage-IaC.ps1 -Action "destroy" -Environment "dev"
```

## Supported Providers

### Terraform (Recommended)
- **Multi-cloud** - AWS, Azure, GCP, and 1000+ providers
- **State management** - Track infrastructure state
- **Modules** - Reusable infrastructure components
- **Plan/Apply** - Preview changes before applying

### CloudFormation (AWS)
- **AWS native** - Deep AWS integration
- **Stack management** - Organized resource groups
- **Change sets** - Preview stack updates
- **Drift detection** - Identify manual changes

### ARM Templates (Azure)
- **Azure native** - Deep Azure integration
- **Resource groups** - Logical organization
- **Template validation** - Pre-deployment checks

## IaC Workflow

### 1. Initialize Project

```powershell
# Terraform
.agent\scripts\Manage-IaC.ps1 -Action "init" -Provider "terraform"

# Creates:
# - terraform/
#   ├── main.tf
#   ├── variables.tf
#   ├── outputs.tf
#   └── terraform.tfvars
```

### 2. Define Infrastructure

**Terraform Example:**
```hcl
# main.tf
terraform {
  required_version = ">= 1.0"
  
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  tags = {
    Name        = "web-server"
    Environment = var.environment
  }
}
```

**CloudFormation Example:**
```yaml
# template.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Web server infrastructure

Parameters:
  InstanceType:
    Type: String
    Default: t3.micro
    
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: !Ref InstanceType
      ImageId: ami-12345678
      Tags:
        - Key: Name
          Value: web-server
```

### 3. Validate Configuration

```powershell
# Check syntax and configuration
.agent\scripts\Manage-IaC.ps1 -Action "validate"
```

Validates:
- Syntax errors
- Required variables
- Provider configuration
- Resource dependencies

### 4. Plan Changes

```powershell
# Preview what will change
.agent\scripts\Manage-IaC.ps1 -Action "plan" -Environment "staging"
```

Shows:
- Resources to create (green +)
- Resources to modify (yellow ~)
- Resources to destroy (red -)
- Estimated cost impact

### 5. Apply Infrastructure

```powershell
# Apply changes
.agent\scripts\Manage-IaC.ps1 -Action "apply" -Environment "staging"
```

Process:
1. Lock state file
2. Create/update resources
3. Update state
4. Unlock state file

### 6. Manage State

```powershell
# View current state
.agent\scripts\Manage-IaC.ps1 -Action "state-list"

# Import existing resource
.agent\scripts\Manage-IaC.ps1 -Action "import" -Resource "aws_instance.web" -Id "i-1234567890"

# Remove from state (doesn't destroy)
.agent\scripts\Manage-IaC.ps1 -Action "state-rm" -Resource "aws_instance.old"
```

## Best Practices

### Project Structure

```
infrastructure/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       └── terraform.tfvars
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   └── database/
└── global/
    └── s3-backend.tf
```

### State Management

**Remote State (Required for Teams):**
```hcl
# Terraform - S3 Backend
terraform {
  backend "s3" {
    bucket         = "company-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

**State Locking:**
- Prevents concurrent modifications
- Uses DynamoDB (AWS) or Azure Blob Storage
- Automatic with remote backends

### Version Control

**DO Commit:**
- ✅ `.tf` files
- ✅ `.tfvars.example` (template)
- ✅ Module definitions
- ✅ Documentation

**DON'T Commit:**
- ❌ `.tfstate` files (use remote backend)
- ❌ `.tfvars` with secrets
- ❌ `.terraform/` directory
- ❌ Credentials or API keys

**.gitignore:**
```
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
!*.tfvars.example

# CloudFormation
packaged-template.yaml
```

### Security

**Secrets Management:**
```hcl
# Use AWS Secrets Manager
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

**Least Privilege:**
```hcl
# IAM policy for Terraform
resource "aws_iam_policy" "terraform" {
  name = "terraform-deployment"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "s3:*",
          "rds:*"
        ]
        Resource = "*"
      }
    ]
  })
}
```

### Modules

**Create Reusable Modules:**
```hcl
# modules/web-server/main.tf
variable "environment" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  
  tags = {
    Environment = var.environment
  }
}

output "instance_id" {
  value = aws_instance.web.id
}
```

**Use Modules:**
```hcl
# environments/prod/main.tf
module "web_server" {
  source = "../../modules/web-server"
  
  environment   = "production"
  instance_type = "t3.large"
}
```

## Testing Infrastructure

### Validation
```powershell
# Syntax check
terraform validate

# Format check
terraform fmt -check

# Security scan
tfsec .
```

### Plan Review
```powershell
# Generate plan
terraform plan -out=tfplan

# Review plan
terraform show tfplan

# Apply only if approved
terraform apply tfplan
```

### Automated Testing
```hcl
# Use Terratest (Go)
func TestWebServer(t *testing.T) {
    terraformOptions := &terraform.Options{
        TerraformDir: "../",
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    instanceID := terraform.Output(t, terraformOptions, "instance_id")
    assert.NotEmpty(t, instanceID)
}
```

## Drift Detection

```powershell
# Detect manual changes
.agent\scripts\Manage-IaC.ps1 -Action "drift-detect"
```

Shows:
- Resources modified outside IaC
- Configuration differences
- Recommended actions

## Cost Estimation

```powershell
# Estimate costs before apply
.agent\scripts\Manage-IaC.ps1 -Action "cost-estimate"
```

Uses:
- Infracost (Terraform)
- AWS Cost Calculator
- Azure Pricing Calculator

## CI/CD Integration

```yaml
# .github/workflows/terraform.yml
name: Terraform

on:
  pull_request:
    paths:
      - 'infrastructure/**'

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        
      - name: Terraform Init
        run: terraform init
        
      - name: Terraform Plan
        run: terraform plan -no-color
        
      - name: Comment PR
        uses: actions/github-script@v6
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: 'Terraform plan output...'
            })
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| State locked | `terraform force-unlock <lock-id>` |
| Drift detected | Review changes, import or apply |
| Plan fails | Check credentials, validate syntax |
| Apply timeout | Increase timeout, check resource limits |
| State corruption | Restore from backup, use state recovery |

## Migration Strategies

### Import Existing Infrastructure
```powershell
# Import AWS instance
terraform import aws_instance.web i-1234567890

# Import entire environment
.agent\scripts\Manage-IaC.ps1 -Action "import-all" -Environment "prod"
```

### Migrate Between Providers
```powershell
# Export from CloudFormation
.agent\scripts\Manage-IaC.ps1 -Action "export" -From "cloudformation"

# Import to Terraform
.agent\scripts\Manage-IaC.ps1 -Action "import" -To "terraform"
```
