# Infrastructure as Code - Quick Reference

## 🚀 Quick Start

### Terraform

```powershell
# Initialize new project
.agent\scripts\Manage-IaC.ps1 -Action "init" -Provider "terraform" -Environment "dev"

# Validate configuration
.agent\scripts\Manage-IaC.ps1 -Action "validate"

# Plan changes
.agent\scripts\Manage-IaC.ps1 -Action "plan" -Environment "dev"

# Apply infrastructure
.agent\scripts\Manage-IaC.ps1 -Action "apply" -Environment "dev"
```

### CloudFormation

```powershell
# Initialize project
.agent\scripts\Manage-IaC.ps1 -Action "init" -Provider "cloudformation" -Environment "dev"

# Validate template
.agent\scripts\Manage-IaC.ps1 -Action "validate" -Provider "cloudformation"

# Deploy stack
.agent\scripts\Manage-IaC.ps1 -Action "apply" -Provider "cloudformation" -Environment "dev"
```

## 📁 Project Structure

```
infrastructure/
├── environments/          # Environment-specific configs
│   ├── dev/
│   ├── staging/
│   └── production/
├── modules/              # Reusable Terraform modules
│   ├── networking/       # VPC, subnets, NAT gateways
│   └── web-app/          # EC2, ALB, auto-scaling
└── cloudformation/       # CloudFormation templates
    └── web-app-complete.yaml
```

## 🎯 What's Included

### Terraform Modules

**Networking Module** (`modules/networking/`)
- VPC with public and private subnets
- Internet Gateway
- NAT Gateways for private subnet internet access
- Route tables and associations
- Multi-AZ support

**Web App Module** (`modules/web-app/`)
- Application Load Balancer
- Auto Scaling Group
- Launch Template
- Security Groups
- CloudWatch alarms for auto-scaling
- Health checks

### CloudFormation Templates

**Complete Web App** (`cloudformation/web-app-complete.yaml`)
- Full VPC setup
- Application Load Balancer
- Auto Scaling Group
- RDS MySQL database
- Security groups
- Multi-AZ support for production

## 🔧 Common Operations

### State Management

```powershell
# List resources in state
.agent\scripts\Manage-IaC.ps1 -Action "state-list"

# Import existing resource
.agent\scripts\Manage-IaC.ps1 -Action "import" -Resource "aws_instance.web" -Id "i-1234567890"
```

### Drift Detection

```powershell
# Detect manual changes
.agent\scripts\Manage-IaC.ps1 -Action "drift-detect" -Environment "production"
```

### Cost Estimation

```powershell
# Estimate costs (requires Infracost)
.agent\scripts\Manage-IaC.ps1 -Action "cost-estimate" -Environment "production"
```

## 📝 Best Practices

1. **Always use remote state** - S3 + DynamoDB for Terraform
2. **Never commit secrets** - Use `.tfvars` in `.gitignore`
3. **Use modules** - Reusable, tested components
4. **Plan before apply** - Review changes first
5. **Tag everything** - Environment, ManagedBy, Project
6. **Enable state locking** - Prevent concurrent modifications
7. **Version your providers** - Pin to specific versions
8. **Use workspaces** - Separate environments

## 🔒 Security

- Store secrets in AWS Secrets Manager / Azure Key Vault
- Use least privilege IAM policies
- Enable encryption for state files
- Scan with tfsec before applying
- Review security group rules carefully

## 📚 Learn More

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS CloudFormation Docs](https://docs.aws.amazon.com/cloudformation/)
- [Infrastructure as Code Workflow](workflows/infrastructure-as-code.md)
