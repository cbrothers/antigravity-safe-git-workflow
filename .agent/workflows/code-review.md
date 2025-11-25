---
description: AI-assisted code review workflow with automated checks
---

# Code Review Workflow

Automated code review process that analyzes changes for security, performance, and code quality issues.

## Usage

```powershell
.agent/scripts/Review-Code.ps1 -BaseBranch "main" -FeatureBranch "feature/my-feature"
```

## What It Checks

### Security
- Hardcoded credentials (passwords, API keys, tokens)
- Insecure functions (Invoke-Expression, eval, etc.)
- SQL injection patterns
- Path traversal vulnerabilities

### Code Quality
- Large functions (>50 lines)
- Excessive complexity
- Debug statements left in code
- TODO/FIXME comments
- Inconsistent naming conventions

### Performance
- Inefficient loops
- Repeated calculations
- Missing caching opportunities

## Review Process

1. **Run automated checks**
   ```powershell
   .agent/scripts/Review-Code.ps1
   ```

2. **Review the generated report**
   - Critical issues are highlighted in red
   - Warnings in yellow
   - Suggestions in gray

3. **Address findings**
   - Fix critical security issues immediately
   - Consider refactoring suggestions
   - Document why you're keeping certain patterns if needed

4. **Re-run to verify**
   ```powershell
   .agent/scripts/Review-Code.ps1
   ```

## Integration with Git Workflow

Use this before merging feature branches:

```powershell
# 1. Review your changes
.agent/scripts/Review-Code.ps1 -FeatureBranch "feature/my-feature"

# 2. Fix any issues
# ... make fixes ...

# 3. Merge when clean
git checkout main
git merge feature/my-feature
```
