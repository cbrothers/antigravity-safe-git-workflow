---
description: Smart file editing workflow using the custom PowerShell patcher script with JSON input
---

# Smart File Editing Workflow

This workflow replaces complex multi-step edits with a single, atomic JSON patch operation. It is designed to be fast, token-efficient, and resilient to whitespace errors.

## The Rule of 3

1.  **Locate**: Identify the file and the minimum unique context needed to locate the code.
2.  **JSON**: Construct a `patch.json` file.
3.  **Execute**: Run `Apply-SmartPatch.ps1`.

## Step 1: Create Patch File

Create a file named `patch.json` in the root (or temp) directory.

**Structure:**

```json
{
  "file": "path/to/target/file.ext",
  "search": "The exact code block you want to replace.\nInclude enough surrounding lines to ensure uniqueness.",
  "replace": "The new code block you want to insert."
}
```

> **Tip:** You do not need to worry perfectly about indentation. The patcher uses "Flexible Matching" if an exact match fails. It treats multiple spaces/newlines as generic whitespace.

## Step 2: Execute

Run the patcher script targeting your JSON file.

```powershell
.agent/scripts/Apply-SmartPatch.ps1 -PatchFile "patch.json"
```

## Step 3: Verify & Cleanup

If the script returns **SUCCESS**, the file is updated. You can now delete the `patch.json`.

```powershell
Remove-Item patch.json
```

## Troubleshooting

| Error | Solution |
| :--- | :--- |
| **Search text not found** | You likely hallucinated the code or the file has changed. Use `Get-Content` to check the file content again. |
| **Ambiguity / Multiple matches** | Your "search" block is too short or generic (e.g., just `}` or `return;`). Add more surrounding lines of code to the "search" block to make it unique. |
| **Invalid JSON** | Ensure you escape quotes `\"` and backslashes `\\` inside the JSON strings correctly. |
