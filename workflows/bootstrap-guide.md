# AI Workflow Bootstrap Guide

## Quick Setup for New Projects

To add the AI-assisted development workflow to any new project:

### Option 1: Automated (Recommended)

1. Navigate to your new project's root directory:
   ```powershell
   cd C:\Path\To\YourNewProject
   ```

2. Run the bootstrap script:
   ```powershell
   & "C:\Users\craig.brothers\Desktop\AI Code Ideas\AI Bands\The Silent Whistle\.agent\scripts\Bootstrap-AIWorkflow.ps1"
   ```

3. Review and customize `.agent/rules.md` for your project.

4. Add the rules to your IDE's "Project Rules" settings.

---

### Option 2: Manual Setup

If you prefer to set up manually, copy these files/folders:

```
YourNewProject/
├── .agent/
│   ├── scripts/
│   │   └── Apply-SmartPatch.ps1
│   ├── workflows/
│   │   └── smart-edit.md
│   ├── tmp/
│   │   └── .gitkeep
│   └── rules.md
└── .gitattributes
```

Then run:
```powershell
git config core.autocrlf false
git config core.eol lf
```

---

## What Gets Installed

- **Apply-SmartPatch.ps1**: The core patching script
- **smart-edit.md**: Workflow documentation
- **rules.md**: AI behavior rules (customize per project)
- **.gitattributes**: Line ending normalization
- **Git config**: LF line endings enforcement
- **.gitignore additions**: Excludes temp files and backups

---

## Customization

After bootstrapping, you may want to:

1. Edit `.agent/rules.md` to add project-specific guidelines
2. Add additional workflows to `.agent/workflows/`
3. Modify `.gitattributes` if you have special file types
