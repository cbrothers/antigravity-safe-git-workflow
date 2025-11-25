# Helper Scripts System

## Purpose
Reduce token usage by offloading repetitive tasks to efficient PowerShell scripts with JSON I/O.

## Architecture
- **Wrapper**: `.agent/scripts/Invoke-Helper.ps1` - Executes helpers with JSON params
- **Registry**: `.agent/scripts/helpers/registry.json` - Documents available helpers
- **Helpers**: `.agent/scripts/helpers/*.ps1` - Individual task scripts

## Usage

### From AI Agent
```
Instead of: Multiple tool calls + large outputs
Use: Single helper call with compressed JSON
```

### Example: Commit Changes
**Old way** (100+ tokens):
```
1. run_command: git add file1.ts
2. run_command: git add file2.ts  
3. run_command: git commit -m "feat: add feature"
4. run_command: git rev-parse HEAD
```

**New way** (20 tokens):
```powershell
.\.agent\scripts\Invoke-Helper.ps1 -HelperName "git-commit" -Params @{
    type = "feat"
    message = "implement license verification"
    files = @("electron/services/LicenseService.ts", "src/components/AuthView.vue")
    issue = 1
}
```

### Example: Update Issue
**Old way** (80+ tokens):
```
1. run_command: gh issue comment 1 --body "Progress update..."
2. command_status: wait for result
3. parse output
```

**New way** (15 tokens):
```powershell
.\.agent\scripts\Invoke-Helper.ps1 -HelperName "issue-update" -Params @{
    issue_number = 1
    action = "progress"
    comment = "Implemented license service and updated UI"
}
```

## Available Helpers

### git-commit
Commits changes with conventional commit format.
- **Params**: `type`, `message`, `files[]`, `body`, `issue`
- **Returns**: `commit_hash`, `success`

### issue-update
Updates GitHub issue with comment and emoji.
- **Params**: `issue_number`, `action`, `comment`
- **Returns**: `issue_url`, `success`

### file-search
Searches for patterns in files.
- **Params**: `pattern`, `path`, `extensions[]`
- **Returns**: `matches[]`

### code-analyze
Analyzes code structure.
- **Params**: `file_path`
- **Returns**: `analysis` (functions, classes, imports)

## Token Savings
- **Typical savings**: 70-90% per operation
- **Compression**: JSON is compressed for large data
- **Caching**: Results can be cached in `.agent/tmp/`

## Adding New Helpers
1. Create `.agent/scripts/helpers/your-helper.ps1`
2. Accept JSON input via stdin or `-InputFile`
3. Output JSON result to stdout
4. Update `registry.json`

## Best Practices
- Keep helpers focused (single responsibility)
- Use JSON for all I/O
- Return structured data
- Handle errors gracefully
- Document params in registry
