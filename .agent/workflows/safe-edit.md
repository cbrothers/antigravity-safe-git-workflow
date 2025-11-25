---
description: Safe file editing workflow using the custom PowerShell patcher script
---

# Safe File Editing Workflow

This workflow describes the safe process for modifying files using the project's custom `Apply-SafePatch.ps1` script. This method is preferred over direct file overwrites as it includes validation, backup creation, and verification.

## Tool Definition: Apply-SafePatch.ps1

The script is located at `.agent/scripts/Apply-SafePatch.ps1`.

### Parameters

| Parameter | Type | Mandatory | Description |
| :--- | :--- | :--- | :--- |
| **`-FilePath`** | String | Yes | The absolute path to the file you want to modify. |
| **`-SearchText`** | String | Yes | The exact text block to find in the file. This must match the existing content character-for-character, including whitespace. |
| **`-ReplaceText`** | String | Yes | The new text block that will replace the `SearchText`. |
| **`-DryRun`** | Switch | No | If specified, the script will only simulate the change and show the difference in file size. No changes will be written to disk. |

## Workflow Steps

### 1. Prepare Content
To avoid command-line escaping issues with complex code or multi-line strings, always write the search and replace blocks to temporary files first.

1.  Create a temporary directory if it doesn't exist: `.agent/tmp/`
2.  Create a file for the **Search Text** (e.g., `.agent/tmp/search.txt`).
    *   Copy the *exact* existing code block you want to replace.
3.  Create a file for the **Replace Text** (e.g., `.agent/tmp/replace.txt`).
    *   Write the new code block you want to insert.

### 2. Execute Patch
Run the script using PowerShell, reading the content from your temporary files.

```powershell
$s = Get-Content ".agent/tmp/search.txt" -Raw
$r = Get-Content ".agent/tmp/replace.txt" -Raw
& ".agent/scripts/Apply-SafePatch.ps1" -FilePath "path/to/target/file" -SearchText $s -ReplaceText $r
```

### 3. Verify Output
Check the script output for the following indicators:
*   **✅ Backup created**: Confirms a backup was made before touching the file.
*   **✅ File updated successfully**: Confirms the write operation worked.
*   **✅ Verification passed**: Confirms the file on disk now matches the intended content.

If you see **❌ ERROR: Search text not found**, double-check your `search.txt` for extra whitespace or missing characters.

### 4. Cleanup
Once the edit is verified, remove the temporary files to keep the workspace clean.

```powershell
Remove-Item .agent/tmp/* -Recurse -Force
```
