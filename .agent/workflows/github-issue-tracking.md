---
description: GitHub issue tracking workflow for AI agent development
---

# GitHub Issue Tracking Workflow

## Overview
Antigravity AI agent integrates with GitHub Issues to track all development work, ensuring proper logging and accountability.

## AI Agent Identity

When commenting on issues, the agent identifies itself as:
```
🤖 **Antigravity AI Agent** - Automated Development Assistant
```

## Workflow Steps

### 1. Starting Work on an Issue

Before beginning any development task:

```powershell
// turbo
# Assign issue to yourself and add "in-progress" label
gh issue edit <issue-number> --add-label "in-progress" --repo cbrothers/merchifai

# Comment on the issue
gh issue comment <issue-number> --repo cbrothers/merchifai --body "🤖 **Antigravity AI Agent** started work on this issue.

**Planned approach:**
- [Brief description of what will be done]

**Estimated completion:** [timeframe]"
```

### 2. During Development

Post progress updates as significant milestones are reached:

```powershell
gh issue comment <issue-number> --repo cbrothers/merchifai --body "🤖 **Antigravity AI Agent** - Progress Update

**Completed:**
- [Task 1]
- [Task 2]

**In Progress:**
- [Current task]

**Blocked/Issues:**
- [Any blockers or issues encountered]"
```

### 3. Committing Code

All commits must reference the issue:

```bash
git commit -m "feat: [description] (#<issue-number>)

- Implementation details
- Any relevant notes

🤖 Automated commit by Antigravity AI Agent"
```

**Commit Convention:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `test:` - Tests
- `refactor:` - Code refactoring
- `chore:` - Maintenance tasks

### 4. Completing Work

When work is finished:

```powershell
gh issue comment <issue-number> --repo cbrothers/merchifai --body "🤖 **Antigravity AI Agent** - Work Complete

**Changes made:**
- [List of changes]

**Files modified:**
- \`path/to/file1.tsx\`
- \`path/to/file2.ts\`

**Testing:**
- [Testing status/results]

**Ready for review:** Yes/No"

# Remove in-progress label, add review label
gh issue edit <issue-number> --remove-label "in-progress" --add-label "ready-for-review" --repo cbrothers/merchifai
```

### 5. Closing Issues

Only close after user approval:

```powershell
gh issue close <issue-number> --repo cbrothers/merchifai --comment "🤖 **Antigravity AI Agent** - Closing issue

**Resolution:**
- [Summary of what was accomplished]

**Verification:**
- [How it was tested/verified]"
```

## Automation Script

Use this helper script for common operations:

```powershell
# Save as: issue-tracker.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$Action,
    
    [Parameter(Mandatory=$true)]
    [int]$IssueNumber,
    
    [string]$Message = "",
    [string]$Repo = "cbrothers/merchifai"
)

$agentSignature = "🤖 **Antigravity AI Agent**"

switch ($Action) {
    "start" {
        gh issue edit $IssueNumber --add-label "in-progress" --repo $Repo
        $body = "$agentSignature started work on this issue.`n`n$Message"
        gh issue comment $IssueNumber --repo $Repo --body $body
        Write-Host "✓ Started work on issue #$IssueNumber" -ForegroundColor Green
    }
    
    "update" {
        $body = "$agentSignature - Progress Update`n`n$Message"
        gh issue comment $IssueNumber --repo $Repo --body $body
        Write-Host "✓ Updated issue #$IssueNumber" -ForegroundColor Green
    }
    
    "complete" {
        gh issue edit $IssueNumber --remove-label "in-progress" --add-label "ready-for-review" --repo $Repo
        $body = "$agentSignature - Work Complete`n`n$Message"
        gh issue comment $IssueNumber --repo $Repo --body $body
        Write-Host "✓ Completed work on issue #$IssueNumber" -ForegroundColor Green
    }
    
    "close" {
        $body = "$agentSignature - Closing issue`n`n$Message"
        gh issue close $IssueNumber --repo $Repo --comment $body
        Write-Host "✓ Closed issue #$IssueNumber" -ForegroundColor Green
    }
}
```

**Usage:**
```powershell
# Start work
.\issue-tracker.ps1 -Action start -IssueNumber 1 -Message "Building landing page component"

# Update progress
.\issue-tracker.ps1 -Action update -IssueNumber 1 -Message "Hero section complete, working on CTA buttons"

# Mark complete
.\issue-tracker.ps1 -Action complete -IssueNumber 1 -Message "Landing page complete, tested on mobile and desktop"

# Close (after user approval)
.\issue-tracker.ps1 -Action close -IssueNumber 1 -Message "Deployed to staging, verified working"
```

## Integration with Task Boundary

When using `task_boundary`, always reference the issue:

```powershell
# At start of task
task_boundary -TaskName "Building Landing Page (#1)" -Mode EXECUTION

# During work
.\issue-tracker.ps1 -Action update -IssueNumber 1 -Message "Components scaffolded"
```

## Additional Best Practices

### Branch Naming Convention
```bash
# Format: type/issue-number-brief-description
git checkout -b feat/1-landing-page
git checkout -b fix/5-auth-redirect
git checkout -b docs/12-api-documentation
```

### Pull Request Template
Create `.github/PULL_REQUEST_TEMPLATE.md`:
```markdown
## Issue Reference
Closes #[issue-number]

## Changes Made
- 
- 

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)


## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated

---
🤖 Created by Antigravity AI Agent
```

### Issue Templates
Create `.github/ISSUE_TEMPLATE/bug_report.md` and `feature_request.md` for standardized issue creation.

## Logging & Metrics

### Track Time Spent
Comment format for time tracking:
```
🤖 **Antigravity AI Agent** - Time Log
**Time spent:** 2.5 hours
**Activity:** Component development and testing
```

### Weekly Summary
Generate weekly progress reports:
```powershell
# List issues worked on this week
gh issue list --repo cbrothers/merchifai --search "commenter:@me updated:>=$(date -d '7 days ago' +%Y-%m-%d)" --json number,title,labels --limit 50
```

## Error Handling

If work encounters blockers:

```powershell
gh issue comment <issue-number> --repo cbrothers/merchifai --body "🤖 **Antigravity AI Agent** - BLOCKED

**Issue encountered:**
[Description of blocker]

**Attempted solutions:**
- [What was tried]

**Requires:**
- User decision/clarification
- External dependency
- Additional research

**Status:** Waiting for resolution"

# Add blocked label
gh issue edit <issue-number> --add-label "blocked" --repo cbrothers/merchifai
```

## Success Criteria

✅ Every code change is linked to an issue
✅ All issues have progress comments from the agent
✅ Commit history shows clear issue references
✅ Labels accurately reflect issue status
✅ Work is traceable and auditable
