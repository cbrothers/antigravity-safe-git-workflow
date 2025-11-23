# Manage-IaC.ps1
# Infrastructure as Code management and automation

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("init", "validate", "plan", "apply", "destroy", "state-list", "import", "drift-detect", "cost-estimate")]
    [string]$Action,
    
    [ValidateSet("terraform", "cloudformation", "arm")]
    [string]$Provider = "terraform",
    
    [ValidateSet("dev", "staging", "production")]
    [string]$Environment = "dev",
    
    [string]$Resource,
    [string]$Id,
    [switch]$AutoApprove,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          INFRASTRUCTURE AS CODE MANAGER                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n🏗️  Provider: $Provider | Environment: $Environment`n" -ForegroundColor Yellow

# ---------------------------------------------------------
# Initialize IaC Project
# ---------------------------------------------------------

if ($Action -eq "init") {
    Write-Host "🚀 Initializing $Provider project...`n" -ForegroundColor Cyan
    
    switch ($Provider) {
        "terraform" {
            # Create directory structure
            $dirs = @(
                "infrastructure/environments/$Environment",
                "infrastructure/modules",
                "infrastructure/global"
            )
            
            foreach ($dir in $dirs) {
                if (-not (Test-Path $dir)) {
                    New-Item -ItemType Directory -Path $dir -Force | Out-Null
                    Write-Host "  ✅ Created $dir" -ForegroundColor Green
                }
            }
            
            # Create main.tf
            $mainTf = @"
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
    key            = "$Environment/terraform.tfstate"
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
    }
  }
}
"@
            
            $mainPath = "infrastructure/environments/$Environment/main.tf"
            if (-not (Test-Path $mainPath)) {
                $mainTf | Set-Content $mainPath
                Write-Host "  ✅ Created $mainPath" -ForegroundColor Green
            }
            
            # Create variables.tf
            $variablesTf = @"
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "$Environment"
}

variable "project_name" {
  description = "Project name"
  type        = string
}
"@
            
            $varsPath = "infrastructure/environments/$Environment/variables.tf"
            if (-not (Test-Path $varsPath)) {
                $variablesTf | Set-Content $varsPath
                Write-Host "  ✅ Created $varsPath" -ForegroundColor Green
            }
            
            # Create outputs.tf
            $outputsTf = @"
output "environment" {
  description = "Environment name"
  value       = var.environment
}
"@
            
            $outputsPath = "infrastructure/environments/$Environment/outputs.tf"
            if (-not (Test-Path $outputsPath)) {
                $outputsTf | Set-Content $outputsPath
                Write-Host "  ✅ Created $outputsPath" -ForegroundColor Green
            }
            
            # Create terraform.tfvars.example
            $tfvarsExample = @"
# Copy to terraform.tfvars and fill in values
aws_region   = "us-east-1"
environment  = "$Environment"
project_name = "my-project"
"@
            
            $examplePath = "infrastructure/environments/$Environment/terraform.tfvars.example"
            $tfvarsExample | Set-Content $examplePath
            Write-Host "  ✅ Created $examplePath" -ForegroundColor Green
            
            # Create .gitignore
            $gitignore = @"
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
!*.tfvars.example
.terraform.lock.hcl

# Crash logs
crash.log
"@
            
            if (-not (Test-Path "infrastructure/.gitignore")) {
                $gitignore | Set-Content "infrastructure/.gitignore"
                Write-Host "  ✅ Created infrastructure/.gitignore" -ForegroundColor Green
            }
            
            Write-Host "`n  📝 Next steps:" -ForegroundColor Cyan
            Write-Host "     1. Copy terraform.tfvars.example to terraform.tfvars" -ForegroundColor Gray
            Write-Host "     2. Fill in your values" -ForegroundColor Gray
            Write-Host "     3. Run: terraform init" -ForegroundColor Gray
        }
        
        "cloudformation" {
            Write-Host "  Creating CloudFormation template..." -ForegroundColor Gray
            
            $template = @"
AWSTemplateFormatVersion: '2010-09-09'
Description: Infrastructure for $Environment environment

Parameters:
  Environment:
    Type: String
    Default: $Environment
    Description: Environment name

Resources:
  # Add your resources here
  
Outputs:
  Environment:
    Description: Environment name
    Value: !Ref Environment
"@
            
            $templatePath = "infrastructure/$Environment-template.yaml"
            $template | Set-Content $templatePath
            Write-Host "  ✅ Created $templatePath" -ForegroundColor Green
        }
    }
}

# ---------------------------------------------------------
# Validate Configuration
# ---------------------------------------------------------

if ($Action -eq "validate") {
    Write-Host "🔍 Validating configuration...`n" -ForegroundColor Cyan
    
    switch ($Provider) {
        "terraform" {
            Push-Location "infrastructure/environments/$Environment"
            try {
                Write-Host "  Running terraform validate..." -ForegroundColor Gray
                terraform validate
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "`n  ✅ Configuration is valid" -ForegroundColor Green
                }
                else {
                    Write-Host "`n  ❌ Validation failed" -ForegroundColor Red
                    exit 1
                }
            }
            finally {
                Pop-Location
            }
        }
        
        "cloudformation" {
            Write-Host "  Validating CloudFormation template..." -ForegroundColor Gray
            aws cloudformation validate-template --template-body "file://infrastructure/$Environment-template.yaml"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✅ Template is valid" -ForegroundColor Green
            }
        }
    }
}

# ---------------------------------------------------------
# Plan Changes
# ---------------------------------------------------------

if ($Action -eq "plan") {
    Write-Host "📋 Planning infrastructure changes...`n" -ForegroundColor Cyan
    
    switch ($Provider) {
        "terraform" {
            Push-Location "infrastructure/environments/$Environment"
            try {
                terraform plan -out=tfplan
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "`n  ✅ Plan generated successfully" -ForegroundColor Green
                    Write-Host "  📄 Plan saved to: tfplan" -ForegroundColor Cyan
                }
            }
            finally {
                Pop-Location
            }
        }
        
        "cloudformation" {
            Write-Host "  Creating change set..." -ForegroundColor Gray
            aws cloudformation create-change-set `
                --stack-name "$Environment-stack" `
                --template-body "file://infrastructure/$Environment-template.yaml" `
                --change-set-name "$Environment-changes-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        }
    }
}

# ---------------------------------------------------------
# Apply Infrastructure
# ---------------------------------------------------------

if ($Action -eq "apply") {
    Write-Host "🚀 Applying infrastructure changes...`n" -ForegroundColor Cyan
    
    if (-not $AutoApprove -and -not $DryRun) {
        $confirm = Read-Host "Apply changes to $Environment? (yes/no)"
        if ($confirm -ne "yes") {
            Write-Host "  ❌ Cancelled" -ForegroundColor Yellow
            exit 0
        }
    }
    
    if ($DryRun) {
        Write-Host "  🔍 DRY RUN - No changes will be made" -ForegroundColor Yellow
        exit 0
    }
    
    switch ($Provider) {
        "terraform" {
            Push-Location "infrastructure/environments/$Environment"
            try {
                if ($AutoApprove) {
                    terraform apply -auto-approve
                }
                else {
                    terraform apply
                }
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "`n  ✅ Infrastructure applied successfully" -ForegroundColor Green
                }
            }
            finally {
                Pop-Location
            }
        }
        
        "cloudformation" {
            Write-Host "  Deploying stack..." -ForegroundColor Gray
            aws cloudformation deploy `
                --stack-name "$Environment-stack" `
                --template-file "infrastructure/$Environment-template.yaml"
        }
    }
}

# ---------------------------------------------------------
# Destroy Infrastructure
# ---------------------------------------------------------

if ($Action -eq "destroy") {
    Write-Host "💥 Destroying infrastructure...`n" -ForegroundColor Red
    
    Write-Host "  ⚠️  WARNING: This will destroy all resources in $Environment!" -ForegroundColor Yellow
    $confirm = Read-Host "Type 'destroy-$Environment' to confirm"
    
    if ($confirm -ne "destroy-$Environment") {
        Write-Host "  ❌ Cancelled" -ForegroundColor Yellow
        exit 0
    }
    
    switch ($Provider) {
        "terraform" {
            Push-Location "infrastructure/environments/$Environment"
            try {
                terraform destroy
                
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "`n  ✅ Infrastructure destroyed" -ForegroundColor Green
                }
            }
            finally {
                Pop-Location
            }
        }
        
        "cloudformation" {
            aws cloudformation delete-stack --stack-name "$Environment-stack"
            Write-Host "  ✅ Stack deletion initiated" -ForegroundColor Green
        }
    }
}

# ---------------------------------------------------------
# State Management
# ---------------------------------------------------------

if ($Action -eq "state-list") {
    Write-Host "📋 Listing state resources...`n" -ForegroundColor Cyan
    
    Push-Location "infrastructure/environments/$Environment"
    try {
        terraform state list
    }
    finally {
        Pop-Location
    }
}

if ($Action -eq "import" -and $Resource -and $Id) {
    Write-Host "📥 Importing resource...`n" -ForegroundColor Cyan
    
    Push-Location "infrastructure/environments/$Environment"
    try {
        terraform import $Resource $Id
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n  ✅ Resource imported successfully" -ForegroundColor Green
        }
    }
    finally {
        Pop-Location
    }
}

# ---------------------------------------------------------
# Drift Detection
# ---------------------------------------------------------

if ($Action -eq "drift-detect") {
    Write-Host "🔍 Detecting infrastructure drift...`n" -ForegroundColor Cyan
    
    Push-Location "infrastructure/environments/$Environment"
    try {
        terraform plan -detailed-exitcode
        
        $exitCode = $LASTEXITCODE
        if ($exitCode -eq 0) {
            Write-Host "`n  ✅ No drift detected" -ForegroundColor Green
        }
        elseif ($exitCode -eq 2) {
            Write-Host "`n  ⚠️  Drift detected - infrastructure differs from state" -ForegroundColor Yellow
        }
    }
    finally {
        Pop-Location
    }
}

# ---------------------------------------------------------
# Cost Estimation
# ---------------------------------------------------------

if ($Action -eq "cost-estimate") {
    Write-Host "💰 Estimating infrastructure costs...`n" -ForegroundColor Cyan
    
    Write-Host "  Checking for Infracost..." -ForegroundColor Gray
    
    try {
        $infracostVersion = infracost --version 2>$null
        if ($infracostVersion) {
            Push-Location "infrastructure/environments/$Environment"
            try {
                infracost breakdown --path .
            }
            finally {
                Pop-Location
            }
        }
        else {
            Write-Host "  💡 Install Infracost for cost estimation:" -ForegroundColor Yellow
            Write-Host "     https://www.infracost.io/docs/" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  💡 Infracost not installed" -ForegroundColor Yellow
    }
}

Write-Host ""
