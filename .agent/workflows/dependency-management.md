---
description: Dependency management and update workflow
---

# Dependency Management Workflow

Track, update, and audit project dependencies safely.

## Overview

Keep dependencies up-to-date while maintaining stability and security.

## Usage

```powershell
# Check for outdated dependencies
.agent/scripts/Manage-Dependencies.ps1 -Action "check"

# Update dependencies
.agent/scripts/Manage-Dependencies.ps1 -Action "update"

# Audit for vulnerabilities
.agent/scripts/Manage-Dependencies.ps1 -Action "audit"
```

## Supported Package Managers

- **PowerShell**: PowerShellGet modules
- **Node.js**: npm/yarn (if package.json exists)
- **Python**: pip (if requirements.txt exists)
- **NuGet**: .NET packages (if .csproj exists)

## Workflow

### 1. Check for Updates

```powershell
.agent/scripts/Manage-Dependencies.ps1 -Action "check"
```

Shows:
- Current versions
- Available updates
- Breaking change warnings
- Security advisories

### 2. Update Dependencies

```powershell
# Update all (minor/patch only)
.agent/scripts/Manage-Dependencies.ps1 -Action "update"

# Include major updates
.agent/scripts/Manage-Dependencies.ps1 -Action "update" -IncludeMajor

# Update specific package
.agent/scripts/Manage-Dependencies.ps1 -Action "update" -Package "PackageName"
```

### 3. Security Audit

```powershell
.agent/scripts/Manage-Dependencies.ps1 -Action "audit"
```

Checks for:
- Known vulnerabilities
- Deprecated packages
- License issues
- Outdated security patches

## Best Practices

### Regular Updates
- **Weekly**: Check for security updates
- **Monthly**: Review and update minor versions
- **Quarterly**: Consider major version updates

### Testing After Updates
```powershell
# Update dependencies
.agent/scripts/Manage-Dependencies.ps1 -Action "update"

# Run tests
.agent/scripts/Run-Tests.ps1

# Run integration tests
.agent/scripts/Run-IntegrationTests.ps1
```

### Version Pinning
- Pin major versions in production
- Use ranges for development
- Document version constraints

## Automated Updates

### CI/CD Integration

```yaml
# Example: Weekly dependency check
schedule:
  - cron: '0 0 * * 1'  # Every Monday

jobs:
  dependency-check:
    runs-on: ubuntu-latest
    steps:
      - name: Check Dependencies
        run: pwsh .agent/scripts/Manage-Dependencies.ps1 -Action "check"
```

### Pull Request Workflow

1. Dependency bot creates PR
2. Automated tests run
3. Security audit runs
4. Team reviews changes
5. Merge if all checks pass

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Breaking changes | Review changelog, update code accordingly |
| Dependency conflicts | Check compatibility matrix, pin versions |
| Security vulnerabilities | Update immediately, check for patches |
| Build failures | Rollback, investigate, fix incrementally |

## Rollback Procedure

If an update causes issues:

```powershell
# Revert to previous commit
git revert HEAD

# Or restore specific files
git restore package.json package-lock.json

# Reinstall dependencies
npm install
```
