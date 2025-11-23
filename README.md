# Antigravity Safe Git Workflow

A bulletproof AI-assisted development workflow using JSON-based patching, flexible whitespace matching, and Git integration.

## 🎯 What Is This?

This workflow solves the common problem of AI coding assistants corrupting files due to:
- Indentation errors
- Line ending inconsistencies  
- Escaping issues in multi-line code blocks
- Lack of verification and rollback

**Solution:** A PowerShell-based "Smart Patch" system that uses JSON for input, flexible regex for matching, and Git for safety.

---

## 🚀 Quick Start

### For New Projects

1. Navigate to your project root:
   ```powershell
   cd C:\Path\To\YourProject
   ```

2. Run the bootstrap script:
   ```powershell
   & "C:\Path\To\Bootstrap-AIWorkflow.ps1"
   ```

3. Add the rules from `.agent/rules.md` to your IDE's "Project Rules" or "Custom Instructions"

4. Start patching!

---

## 📦 What Gets Installed

```
YourProject/
├── .agent/
│   ├── scripts/
│   │   └── Apply-SmartPatch.ps1    # Core patching engine
│   ├── workflows/
│   │   └── smart-edit.md           # Workflow documentation
│   ├── tmp/                        # Temp files (gitignored)
│   └── rules.md                    # AI behavior rules
├── .gitattributes                  # Line ending normalization
└── .gitignore                      # Updated with AI workflow exclusions
```

---

## 🔧 How It Works

### The Workflow (3 Steps)

1. **Draft**: Create a `patch.json` file:
   ```json
   {
     "file": "src/app.js",
     "search": "function oldCode() {\n  return 'old';\n}",
     "replace": "function newCode() {\n  return 'new';\n}"
   }
   ```

2. **Apply**: Run the patcher:
   ```powershell
   .agent/scripts/Apply-SmartPatch.ps1 -PatchFile "patch.json"
   ```

3. **Verify**: Read the Git diff output and confirm the change.

### Key Features

- ✅ **Exact Match First**: Tries exact string matching for speed
- ✅ **Flexible Fallback**: Uses regex with whitespace normalization if exact fails
- ✅ **Git Integration**: Shows diffs, creates backups, supports branching
- ✅ **Binary Guard**: Prevents accidental corruption of images/binaries
- ✅ **Auto-Commit**: Optional auto-commit when using feature branches

---

## 📖 Documentation

- **[Bootstrap Guide](workflows/bootstrap-guide.md)** - Detailed setup instructions
- **[Smart Edit Workflow](workflows/smart-edit.md)** - Step-by-step usage guide
- **[AI Rules](rules.md)** - Copy this to your IDE's project rules

---

## 🛠️ Advanced Usage

### Feature Branch Mode

```powershell
.agent/scripts/Apply-SmartPatch.ps1 -PatchFile "patch.json" -BranchName "ai/new-feature"
```

This will:
1. Create/checkout the branch
2. Apply the patch
3. Auto-commit with a descriptive message

### Error Handling

If a patch fails:
- The script outputs the error (e.g., "Search text not found")
- The file is **not modified** (safe by default)
- Fix your `search` block in `patch.json` and retry

---

## 🤖 IDE Integration

### Antigravity / Cursor / Windsurf

Add this to your **Project Rules**:

```markdown
# Code Editing Protocol (MANDATORY)
You MUST use the "Smart Patch" workflow for all file modifications.
See .agent/rules.md for full documentation.
```

---

## 🌟 Why This Approach?

| Problem | Solution |
|---------|----------|
| AI hallucinates indentation | Flexible whitespace regex matching |
| Escaping nightmares in CLI | JSON input with proper escaping |
| No verification | Git diff output for every change |
| Accidental corruption | Binary file guard + automatic backups |
| Hard to rollback | Git integration with optional branching |

---

## 📝 License

MIT License - Feel free to use in your projects!

---

## 🙏 Credits

Created by [@cbrothers](https://github.com/cbrothers) for use with AI coding assistants like Antigravity, Cursor, and Windsurf.