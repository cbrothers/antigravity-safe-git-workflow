# AI BEHAVIOR RULES

## 1. GIT-BACKED SMART EDITING (MANDATORY)

You are strictly FORBIDDEN from rewriting entire files.
You MUST use the "Smart Patch" workflow.

### The Workflow:

1. **Draft**: Create `patch.json` (target file, search block, replace block).

2. **Apply**: Run `./.agent/scripts/Apply-SmartPatch.ps1 -PatchFile "patch.json"`
   - *Optional*: Add `-BranchName "ai/feat-name"` if implementing a complex feature.

3. **Verify via Diff**:
   - The script will output a `--- GIT DIFF START ---` section.
   - **READ THE DIFF**. If the diff looks correct (e.g., `- old line` / `+ new line`), the task is DONE.
   - **DO NOT** read the file content again unless the diff is confusing or empty.

4. **Cleanup**: `Remove-Item patch.json -Force` (auto-run, no approval needed).

### Error Handling:

- If the script fails, it will auto-revert (via logic or you can run `git restore <file>`).
- Do not attempt to use `sed` or `Get-Content` rewriting as a fallback. Fix the search block in `patch.json` and retry.

## 2. TERMINAL & SHELL

- Always use PowerShell.
- Rely on `git status` and `git diff` to understand state changes.
- **Auto-run cleanup**: You may auto-run `Remove-Item` on temporary files you create (e.g., `.agent/tmp/*`, `patch.json`) without user approval.

## 3. LINE ENDINGS

- The project uses **LF (Unix-style)** line endings for all text files.
- When creating patch JSON files, use `\n` for newlines, NOT `\r\n`.
- Git is configured to normalize line endings automatically via `.gitattributes`.
