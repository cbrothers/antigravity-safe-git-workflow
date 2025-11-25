---
description: Onboarding workflow for new team members
---

# Developer Onboarding Workflow

Streamlined onboarding process for new developers joining the project.

## For New Developers

### Quick Start Checklist

```powershell
# Run the onboarding script
.agent/scripts/Onboard-Developer.ps1
```

This will:
- ✅ Verify all required tools are installed
- ✅ Clone and configure the repository
- ✅ Set up development environment
- ✅ Run initial tests to verify setup
- ✅ Generate personalized onboarding guide

## What Gets Checked

### Required Tools
- Git (with proper configuration)
- PowerShell 7+ (or Windows PowerShell 5.1+)
- Code editor (VS Code recommended)
- Pester (for testing)

### Optional Tools
- Docker (for containerized development)
- Node.js (if applicable)
- Database tools (if applicable)

## Environment Setup

The script will:
1. Configure Git with recommended settings
2. Set up Git hooks for quality checks
3. Create local configuration files
4. Install project dependencies
5. Verify all systems are working

## First Tasks

After onboarding, new developers should:

1. **Read Documentation**
   - Project README
   - Architecture overview
   - Coding standards

2. **Run Tests**
   ```powershell
   .agent/scripts/Run-Tests.ps1
   ```

3. **Try a Small Change**
   - Pick a "good first issue"
   - Create a feature branch
   - Make changes using Smart Patch workflow
   - Submit for review

## Getting Help

- 📚 Check `.agent/workflows/` for workflow guides
- 🔍 Use code review workflow to learn patterns
- 💬 Ask questions in team chat
- 📝 Update documentation when you learn something new

## For Mentors

### Onboarding Checklist

- [ ] Assign a mentor
- [ ] Grant repository access
- [ ] Add to team communication channels
- [ ] Schedule pairing sessions
- [ ] Review first PR together
- [ ] Introduce to team workflows

### Recommended Timeline

**Week 1:**
- Environment setup
- Read documentation
- Shadow senior developers

**Week 2:**
- First small PR
- Attend code reviews
- Learn deployment process

**Week 3:**
- Independent feature work
- Participate in planning
- Start reviewing others' code

## Common Issues

| Issue | Solution |
|-------|----------|
| Git authentication fails | Set up SSH keys or personal access token |
| Tests fail on setup | Check dependencies, verify environment variables |
| Permission errors | Ensure proper file permissions, run as admin if needed |
| Tool version mismatch | Update to required versions |
