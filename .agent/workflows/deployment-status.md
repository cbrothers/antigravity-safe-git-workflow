---
description: View deployment status across all environments
---

# Deployment Status Dashboard

Displays the current deployment status for all environments.

## Usage

```powershell
.\.agent\scripts\Get-DeploymentStatus.ps1
```

## What It Shows

### 📦 Project Information
- Project name (auto-detected from git remote)
- Current branch you're on

### 📊 Branch Status
- Latest commit on `main`, `stage`, and `production` branches
- Commit hash, message, and time

### 🌐 Environment Status
- URLs for each environment
- Live status check (✅ accessible / ⚠️ unreachable)

### 📈 Deployment Pipeline
- Shows if Stage is in sync with Main
- Shows if Production is in sync with Stage
- Displays how many commits behind each environment is

## Example Output

```
╔════════════════════════════════════════════════════════════════╗
║          DEPLOYMENT STATUS DASHBOARD                          ║
╚════════════════════════════════════════════════════════════════╝

📦 Project: TheSilentWhistleBandWebsite
🌿 Current Branch: main

📊 BRANCH STATUS

  main           9bedd4e - Fix version timestamp (1 hour ago)
  stage          709b68c - Fix Maya pet image (2 hours ago)
  production     6b255e0 - Setup deployment pipeline (3 hours ago)

🌐 ENVIRONMENT STATUS

  Stage          https://stage.thesilentwhistleband.com ✅
  Production     https://www.thesilentwhistleband.com ✅

📈 DEPLOYMENT PIPELINE

  Stage ← Main:       ⚠️  2 commit(s) behind
  Production ← Stage: ⚠️  1 commit(s) behind
```

## Customization

You can customize the environments by passing a hashtable:

```powershell
$envs = @{
    "Dev" = "https://dev.example.com"
    "Stage" = "https://stage.example.com"
    "Production" = "https://www.example.com"
}

.\.agent\scripts\Get-DeploymentStatus.ps1 -Environments $envs
```
