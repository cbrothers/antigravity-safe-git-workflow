---
description: Running unit tests for AI workflow scripts
---

# Testing AI Workflow Scripts

This project uses **Pester** (PowerShell's testing framework) to ensure the reliability of automation scripts.

## Quick Start

Run all tests:
```powershell
.\.agent\scripts\Run-Tests.ps1
```

Run with detailed output:
```powershell
.\.agent\scripts\Run-Tests.ps1 -Detailed
```

## Test Coverage

### Apply-SmartPatch.Tests.ps1
Tests for the core patching script:
- ✅ Exact match patching
- ✅ Flexible whitespace matching
- ✅ Line ending normalization (CRLF → LF)
- ✅ Binary file rejection
- ✅ Multi-file patch arrays
- ✅ Error handling (missing files, no matches)

### Deploy-Site.Tests.ps1
Tests for the deployment automation:
- ✅ Parameter validation
- ✅ Target environment enforcement (Stage/Production)
- ✅ Message requirement for Stage deployments

### Bootstrap-AIWorkflow.Tests.ps1
Tests for project setup:
- ✅ Directory structure creation
- ✅ Script file copying
- ✅ Git configuration (.gitattributes, .gitignore)

## Prerequisites

Pester will be automatically installed if not present when running `Run-Tests.ps1`.

To manually install Pester:
```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

## CI/CD Integration

Add to your CI pipeline:
```yaml
- name: Run PowerShell Tests
  run: .\.agent\scripts\Run-Tests.ps1
```

## Writing New Tests

Follow the Pester convention:
1. Name test files `<ScriptName>.Tests.ps1`
2. Place in `.agent/scripts/` directory
3. Use `Describe`, `Context`, `It` blocks
4. Use `BeforeAll`/`AfterAll` for setup/cleanup

Example:
```powershell
Describe "MyScript.ps1" {
    Context "Feature X" {
        It "Should do Y" {
            # Arrange
            $input = "test"
            
            # Act
            $result = & ./MyScript.ps1 -Input $input
            
            # Assert
            $result | Should -Be "expected"
        }
    }
}
```
