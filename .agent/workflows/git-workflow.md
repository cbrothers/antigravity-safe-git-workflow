---
description: Safe git workflow for making changes
---

# Git Feature Branch Workflow

This workflow ensures safe, reversible changes using git branches.

## When to Use
Use this workflow for ANY code changes to avoid corrupting the main branch.

## Steps

// turbo
### 1. Create a Feature Branch
Before making ANY changes, create a new branch:
```powershell
git checkout -b feature/descriptive-name
```
Examples:
- `feature/add-contact-form`
- `feature/update-hero-section`
- `feature/fix-mobile-layout`

### 2. Make Your Changes
Edit files as needed. All changes are isolated to this branch.

// turbo
### 3. Stage and Commit Changes
When done with changes:
```powershell
git add .
git commit -m "feat: Brief description of changes"
```

Use conventional commit prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `style:` - CSS/styling changes
- `refactor:` - Code restructuring
- `docs:` - Documentation only

### 4. User Reviews Changes
The user can now:
- Test the changes in browser
- Review the code
- Decide to keep or discard

## User Actions After Review

### Option A: Keep Changes (Merge to Main)
**Review the changes, then approve the merge:**
```powershell
git checkout main
git merge feature/branch-name
git branch -D feature/branch-name
```

### Option B: Discard Changes (Delete Branch)
**If changes aren't needed:**
```powershell
git checkout main
git branch -D feature/branch-name
```

### Option C: Push to Production
**After merging to main, deploy to live site:**
```powershell
git push origin main
```

## Benefits
✅ Main branch stays clean and stable
✅ Easy to revert bad changes (just delete feature branch)
✅ Can test changes before committing to main
✅ Safe patcher creates automatic backups
✅ Clear history of what changed
✅ AI can work freely in feature branches
✅ You only approve at merge and deployment points

## Important Notes
- **Feature branches are safe** - AI can auto-create, edit, and commit
- **Safe patcher creates backups** - all file edits are reversible
- **You approve at two points**: 
  1. Merging feature → main (review changes)
  2. Pushing main → production (go live decision)
- Use descriptive branch names
- Delete feature branches after merging or discarding
