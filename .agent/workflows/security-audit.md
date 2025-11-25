---
description: Security audit workflow to scan for vulnerabilities
---

# Security Audit Workflow

Comprehensive security scanning for common vulnerabilities and misconfigurations.

## Usage

```powershell
.agent/scripts/Audit-Security.ps1 -ScanPath "."
```

## What It Scans

### Credential Leaks
- Hardcoded passwords
- API keys and tokens
- Private keys
- Database connection strings

### Insecure Practices
- Weak cryptography
- Insecure deserialization
- Command injection vectors
- Path traversal risks

### Configuration Issues
- World-writable files (Unix/Linux)
- Exposed .git directories
- Debug mode enabled
- Verbose error messages

## Running Regular Audits

### Before Commits
```powershell
# Add to pre-commit hook
.agent/scripts/Audit-Security.ps1
```

### Weekly Scans
```powershell
# Full repository scan
.agent/scripts/Audit-Security.ps1 -ScanPath "." -Verbose
```

### CI/CD Integration
```yaml
# Example GitHub Actions
- name: Security Audit
  run: pwsh .agent/scripts/Audit-Security.ps1
```

## Remediation

When issues are found:

1. **Critical**: Fix immediately before any commit
2. **High**: Address within 24 hours
3. **Medium**: Plan fix in next sprint
4. **Low**: Document as technical debt

## False Positives

If you have legitimate use cases:

```powershell
# Add exception comments
$apiKey = "test-key-12345"  # SECURITY-EXCEPTION: Test fixture only
```
