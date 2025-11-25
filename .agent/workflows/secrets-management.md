---
description: Secrets management workflow for secure credential handling
---

# Secrets Management

Secure storage, rotation, and access control for credentials, API keys, and sensitive configuration.

## Overview

Never store secrets in code or configuration files. Use dedicated secrets management solutions with encryption, access control, and audit logging.

## Usage

```powershell
# Initialize secrets management
.agent\scripts\Manage-Secrets.ps1 -Action "init" -Provider "vault"

# Store a secret
.agent\scripts\Manage-Secrets.ps1 -Action "set" -Path "prod/db/password" -Value "SecurePassword123!"

# Retrieve a secret
.agent\scripts\Manage-Secrets.ps1 -Action "get" -Path "prod/db/password"

# Rotate a secret
.agent\scripts\Manage-Secrets.ps1 -Action "rotate" -Path "prod/api/key"

# List secrets
.agent\scripts\Manage-Secrets.ps1 -Action "list" -Path "prod/"
```

## Supported Providers

### HashiCorp Vault (Recommended for Multi-Cloud)
- **Encryption** - AES-256 encryption at rest
- **Dynamic Secrets** - Generate credentials on-demand
- **Lease Management** - Automatic secret expiration
- **Audit Logging** - Complete access history
- **Multi-Cloud** - Works everywhere

### AWS Secrets Manager
- **AWS Integration** - Native AWS service integration
- **Automatic Rotation** - Built-in rotation for RDS, etc.
- **Versioning** - Track secret changes
- **Fine-grained IAM** - AWS IAM policies
- **Regional** - Replicate across regions

### Azure Key Vault
- **Azure Integration** - Native Azure service integration
- **HSM Support** - Hardware security modules
- **Managed Identities** - No credentials needed for Azure resources
- **Versioning** - Track secret history
- **Soft Delete** - Recover deleted secrets

### AWS Systems Manager Parameter Store
- **Free Tier** - Standard parameters are free
- **Simple** - Easy to use
- **Integration** - Works with CloudFormation, ECS, etc.
- **Hierarchical** - Organize with paths
- **Limited** - No automatic rotation

## Secrets Management Workflow

### 1. Initialize Secrets Backend

```powershell
# HashiCorp Vault
.agent\scripts\Manage-Secrets.ps1 -Action "init" -Provider "vault"

# AWS Secrets Manager
.agent\scripts\Manage-Secrets.ps1 -Action "init" -Provider "aws-secrets"

# Azure Key Vault
.agent\scripts\Manage-Secrets.ps1 -Action "init" -Provider "azure-keyvault"
```

### 2. Store Secrets

```powershell
# Database password
.agent\scripts\Manage-Secrets.ps1 -Action "set" `
    -Path "prod/db/password" `
    -Value "SecurePassword123!"

# API key with metadata
.agent\scripts\Manage-Secrets.ps1 -Action "set" `
    -Path "prod/api/stripe-key" `
    -Value "sk_live_..." `
    -Metadata @{owner="platform-team"; expires="2025-12-31"}

# JSON secret
.agent\scripts\Manage-Secrets.ps1 -Action "set" `
    -Path "prod/oauth/credentials" `
    -Value '{"client_id":"abc","client_secret":"xyz"}'
```

### 3. Retrieve Secrets

```powershell
# Get secret value
$password = .agent\scripts\Manage-Secrets.ps1 -Action "get" -Path "prod/db/password"

# Get secret with metadata
.agent\scripts\Manage-Secrets.ps1 -Action "get" -Path "prod/api/key" -IncludeMetadata
```

### 4. Rotate Secrets

```powershell
# Manual rotation
.agent\scripts\Manage-Secrets.ps1 -Action "rotate" -Path "prod/db/password"

# Automatic rotation (AWS Secrets Manager)
.agent\scripts\Manage-Secrets.ps1 -Action "enable-rotation" `
    -Path "prod/db/password" `
    -RotationDays 30
```

### 5. Delete Secrets

```powershell
# Soft delete (recoverable)
.agent\scripts\Manage-Secrets.ps1 -Action "delete" -Path "dev/temp/key"

# Permanent delete
.agent\scripts\Manage-Secrets.ps1 -Action "delete" -Path "dev/temp/key" -Permanent
```

## Best Practices

### Never Commit Secrets
```bash
# .gitignore
*.env
*.tfvars
secrets.yaml
credentials.json
.aws/credentials
.vault-token
```

### Use Environment-Specific Paths
```
secrets/
├── dev/
│   ├── db/password
│   └── api/key
├── staging/
│   ├── db/password
│   └── api/key
└── prod/
    ├── db/password
    └── api/key
```

### Implement Least Privilege
```hcl
# Vault policy - read-only for app
path "secret/data/prod/db/*" {
  capabilities = ["read"]
}

# Vault policy - full access for ops
path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
```

### Enable Audit Logging
```powershell
# Vault audit log
vault audit enable file file_path=/var/log/vault_audit.log

# AWS CloudTrail for Secrets Manager
# (enabled by default)
```

### Rotate Regularly
- **Database passwords**: Every 90 days
- **API keys**: Every 90 days
- **Certificates**: Before expiration
- **Service accounts**: Every 180 days

## Integration Examples

### Terraform
```hcl
# Read from Vault
data "vault_generic_secret" "db_password" {
  path = "secret/prod/db/password"
}

resource "aws_db_instance" "main" {
  password = data.vault_generic_secret.db_password.data["value"]
}
```

### CloudFormation
```yaml
# Read from Secrets Manager
Resources:
  Database:
    Type: AWS::RDS::DBInstance
    Properties:
      MasterUserPassword: !Sub '{{resolve:secretsmanager:prod/db/password:SecretString:password}}'
```

### Application Code

**Node.js:**
```javascript
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager();

async function getSecret(secretName) {
  const data = await secretsManager.getSecretValue({
    SecretId: secretName
  }).promise();
  
  return JSON.parse(data.SecretString);
}

const dbCreds = await getSecret('prod/db/credentials');
```

**Python:**
```python
import boto3
import json

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

db_creds = get_secret('prod/db/credentials')
```

**PowerShell:**
```powershell
# AWS Secrets Manager
$secret = Get-SECSecretValue -SecretId "prod/db/password"
$password = ($secret.SecretString | ConvertFrom-Json).password

# Azure Key Vault
$secret = Get-AzKeyVaultSecret -VaultName "my-vault" -Name "db-password"
$password = $secret.SecretValue | ConvertFrom-SecureString -AsPlainText
```

## Secret Rotation

### Automatic Rotation (AWS)
```powershell
# Enable rotation for RDS
aws secretsmanager rotate-secret `
    --secret-id prod/db/password `
    --rotation-lambda-arn arn:aws:lambda:us-east-1:123456789012:function:SecretsManagerRotation `
    --rotation-rules AutomaticallyAfterDays=30
```

### Manual Rotation Script
```powershell
# Rotate database password
.agent\scripts\Manage-Secrets.ps1 -Action "rotate" -Path "prod/db/password" -UpdateDatabase
```

### Rotation Strategy
1. **Generate new secret**
2. **Store as new version**
3. **Update application configuration**
4. **Test with new secret**
5. **Deprecate old secret**
6. **Delete old secret after grace period**

## Access Control

### Vault Policies
```hcl
# Developer policy - read dev secrets
path "secret/data/dev/*" {
  capabilities = ["read", "list"]
}

# Operations policy - manage prod secrets
path "secret/data/prod/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

# Application policy - read specific secrets
path "secret/data/prod/app/*" {
  capabilities = ["read"]
}
```

### AWS IAM Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:123456789012:secret:prod/*"
    }
  ]
}
```

### Azure RBAC
```powershell
# Grant read access to Key Vault
New-AzRoleAssignment `
    -ObjectId $appObjectId `
    -RoleDefinitionName "Key Vault Secrets User" `
    -Scope "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/my-vault"
```

## Monitoring & Alerts

### Vault Audit Events
- Secret access (read)
- Secret modifications (create, update, delete)
- Failed authentication attempts
- Policy violations

### AWS CloudWatch Alarms
```powershell
# Alert on secret access
aws cloudwatch put-metric-alarm `
    --alarm-name "SecretAccessed" `
    --metric-name "SecretAccess" `
    --namespace "AWS/SecretsManager" `
    --statistic Sum `
    --period 300 `
    --threshold 100 `
    --comparison-operator GreaterThanThreshold
```

## Compliance

### Audit Requirements
- **Who** accessed which secret
- **When** was it accessed
- **From where** (IP address, service)
- **What** action was performed

### Retention Policies
- Audit logs: 1-7 years (compliance dependent)
- Deleted secrets: 7-30 days recovery window
- Secret versions: Keep last 10 versions

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Access denied | Check IAM/RBAC policies |
| Secret not found | Verify path and permissions |
| Rotation failed | Check Lambda/function logs |
| Expired credentials | Rotate secret immediately |
| Audit log full | Increase storage or archive |

## Migration Strategies

### From Environment Variables
```powershell
# Export env vars to secrets
Get-ChildItem Env: | Where-Object { $_.Name -like "DB_*" } | ForEach-Object {
    .agent\scripts\Manage-Secrets.ps1 -Action "set" `
        -Path "prod/env/$($_.Name)" `
        -Value $_.Value
}
```

### From Config Files
```powershell
# Import from JSON
$config = Get-Content "config.json" | ConvertFrom-Json
$config.PSObject.Properties | ForEach-Object {
    .agent\scripts\Manage-Secrets.ps1 -Action "set" `
        -Path "prod/config/$($_.Name)" `
        -Value $_.Value
}
```

## Emergency Procedures

### Compromised Secret
1. **Immediately rotate** the secret
2. **Revoke access** to old version
3. **Audit logs** to identify scope
4. **Update applications** with new secret
5. **Investigate** how compromise occurred
6. **Document** incident and remediation

### Lost Access
1. Use **break-glass** emergency credentials
2. **Restore** from backup if available
3. **Re-create** secrets if necessary
4. **Update** access policies
5. **Review** and improve procedures
