<#
.SYNOPSIS
    Apply-SmartPatch.ps1 (Git Enhanced + Binary Guard)
    
.DESCRIPTION
    Applies JSON patches with flexible whitespace matching.
    Leverages GIT for safety, rollbacks, and diff generation.
    PREVENTS accidental patching of binary files.

.EXAMPLE
    ./Apply-SmartPatch.ps1 -PatchFile "patch.json" -BranchName "ai/fix-header"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$PatchFile,

    [Parameter(Mandatory = $false)]
    [string]$BranchName
)

$ErrorActionPreference = "Stop"
$pathIsGitTracked = Test-Path ".git"

# ---------------------------------------------------------
# 1. Setup, Validation & Binary Guard
# ---------------------------------------------------------

try {
    $patchData = Get-Content -Path $PatchFile -Raw | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON patch file."
}

$targetPath = $patchData.file
$searchText = $patchData.search
$replaceText = $patchData.replace

if (-not (Test-Path $targetPath)) { Write-Error "Target file not found: $targetPath" }

# BINARY GUARD: Prevent corruption of non-text files
$binaryExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".pdf", ".exe", ".dll", ".bin", ".zip", ".tar", ".gz", ".7z")
$extension = [System.IO.Path]::GetExtension($targetPath).ToLower()
if ($binaryExtensions -contains $extension) {
    Write-Error "ABORTED :: Target '$targetPath' appears to be a binary file. Text patching would corrupt it."
}

# GIT: Handle Branching
if ($pathIsGitTracked -and -not [string]::IsNullOrWhiteSpace($BranchName)) {
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $BranchName) {
        Write-Host "GIT :: Switching to feature branch '$BranchName'..." -ForegroundColor Cyan
        # Try checkout, else create
        git checkout $BranchName 2>$null
        if ($LASTEXITCODE -ne 0) {
            git checkout -b $BranchName
        }
    }
}

# GIT: Safety Snapshot
if ($pathIsGitTracked) {
    $status = git status --porcelain $targetPath
    if (-not [string]::IsNullOrWhiteSpace($status)) {
        Write-Warning "GIT :: File has uncommitted changes. Patching on top of dirty state."
    }
}

# ---------------------------------------------------------
# 2. Apply Patch (Flexible Logic)
# ---------------------------------------------------------
# Force UTF8 to ensure consistent behavior for code files
$originalContent = Get-Content -Path $targetPath -Raw -Encoding UTF8

# Try Exact
if ($originalContent.Contains($searchText)) {
    Write-Host "MATCH :: Exact match." -ForegroundColor Green
    $newContent = $originalContent.Replace($searchText, $replaceText)
}
else {
    # Try Flexible
    Write-Host "RETRY :: Relaxing whitespace..." -ForegroundColor Yellow
    $escapedSearch = [regex]::Escape($searchText)
    $flexiblePattern = $escapedSearch -replace "\\r", "" -replace "\\n", "" -replace "\\s+", "\s+"
    $regex = [regex]::new($flexiblePattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    if ($regex.Matches($originalContent).Count -eq 0) {
        Write-Error "FAILURE :: Content not found."
    }
    $newContent = $regex.Replace($originalContent, $replaceText, 1)
}

# Write to disk (Enforce UTF8 NoBOM for modern code compatibility)
$newContent | Set-Content -Path $targetPath -NoNewline -Encoding UTF8

# ---------------------------------------------------------
# 3. Verification & Diff
# ---------------------------------------------------------

if ($pathIsGitTracked) {
    # Check what happened using Git
    $diff = git diff --no-color --unified=0 $targetPath
    
    if (-not [string]::IsNullOrWhiteSpace($diff)) {
        Write-Host "SUCCESS :: File patched." -ForegroundColor Green
        Write-Host "`n--- GIT DIFF START ---" -ForegroundColor Gray
        Write-Host $diff
        Write-Host "--- GIT DIFF END ---`n" -ForegroundColor Gray
        
        # Optional: Auto-commit if in feature branch
        if (-not [string]::IsNullOrWhiteSpace($BranchName)) {
            git add $targetPath
            git commit -m "AI Patch: Update $targetPath"
            Write-Host "GIT :: Committed to $BranchName" -ForegroundColor Cyan
        }
    }
    else {
        Write-Error "NO CHANGE :: File content matched, but result is identical to original."
    }
}
else {
    Write-Host "SUCCESS :: File updated (No git repo detected)." -ForegroundColor Green
}