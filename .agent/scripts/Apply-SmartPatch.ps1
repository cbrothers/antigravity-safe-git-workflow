<#
.SYNOPSIS
    Apply-SmartPatch.ps1 (Multi-File Support)
    
.DESCRIPTION
    Applies JSON patches with flexible whitespace matching.
    Supports both single patch objects and arrays of patch objects.
    Leverages GIT for safety, rollbacks, and diff generation.
    PREVENTS accidental patching of binary files.

.EXAMPLE
    ./Apply-SmartPatch.ps1 -PatchFile "patch.json"
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
# 1. Parse Patch Data
# ---------------------------------------------------------

try {
    $jsonContent = Get-Content -Path $PatchFile -Raw
    $patchData = $jsonContent | ConvertFrom-Json
}
catch {
    Write-Error "Failed to parse JSON patch file."
}

# Normalize to array
if ($patchData -isnot [System.Array]) {
    $patchData = @($patchData)
}

# ---------------------------------------------------------
# 1.5. Validate All Patches Before Applying
# ---------------------------------------------------------

Write-Host "`nValidating patches..." -ForegroundColor Cyan

foreach ($patch in $patchData) {
    if (-not $patch.file) { 
        Write-Error "Patch missing 'file' property" 
    }
    if (-not $patch.PSObject.Properties['search']) { 
        Write-Error "Patch missing 'search' property for file: $($patch.file)" 
    }
    if (-not $patch.PSObject.Properties['replace']) { 
        Write-Error "Patch missing 'replace' property for file: $($patch.file)" 
    }
    if (-not (Test-Path $patch.file)) { 
        Write-Error "File not found: $($patch.file)" 
    }
}

Write-Host "✅ All patches validated" -ForegroundColor Green

# ---------------------------------------------------------
# 1.6. Handle Git Branching (Once, Before All Patches)
# ---------------------------------------------------------

if ($pathIsGitTracked -and -not [string]::IsNullOrWhiteSpace($BranchName)) {
    $currentBranch = git branch --show-current
    if ($currentBranch -ne $BranchName) {
        Write-Host "`nSwitching to branch: $BranchName" -ForegroundColor Cyan
        git checkout $BranchName 2>$null
        if ($LASTEXITCODE -ne 0) { 
            git checkout -b $BranchName 
            Write-Host "✅ Created new branch: $BranchName" -ForegroundColor Green
        }
        else {
            Write-Host "✅ Switched to existing branch: $BranchName" -ForegroundColor Green
        }
    }
}

# ---------------------------------------------------------
# 1.7. Create Rollback Point
# ---------------------------------------------------------

$stashCreated = $false
if ($pathIsGitTracked) {
    # Check if there are any changes to stash
    $status = git status --porcelain
    if ($status) {
        $stashName = "pre-patch-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        git stash push -m $stashName
        $stashCreated = $true
        Write-Host "✅ Created rollback point: $stashName" -ForegroundColor Green
    }
}

# ---------------------------------------------------------
# 2. Process Patches
# ---------------------------------------------------------

foreach ($patch in $patchData) {
    $targetPath = $patch.file
    $searchText = $patch.search
    $replaceText = $patch.replace

    Write-Host "`nProcessing: $targetPath" -ForegroundColor Cyan

    if (-not (Test-Path $targetPath)) { 
        Write-Error "Target file not found: $targetPath" 
    }

    # BINARY GUARD (Enhanced)
    $binaryExtensions = @(
        ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".svg", ".webp",
        ".pdf", ".exe", ".dll", ".bin", ".so", ".dylib",
        ".zip", ".tar", ".gz", ".7z", ".rar",
        ".mp4", ".avi", ".mov", ".webm", ".mkv",
        ".mp3", ".wav", ".flac", ".ogg",
        ".woff", ".woff2", ".ttf", ".eot", ".otf"
    )
    $extension = [System.IO.Path]::GetExtension($targetPath).ToLower()
    if ($binaryExtensions -contains $extension) {
        Write-Error "ABORTED :: Target '$targetPath' appears to be a binary file."
    }

    # Apply Patch Logic
    $originalContent = Get-Content -Path $targetPath -Raw -Encoding UTF8
    
    # Normalize line endings
    $normalizedContent = $originalContent -replace "`r`n", "`n"
    $normalizedSearch = $searchText -replace "`r`n", "`n"

    if ($normalizedContent.Contains($normalizedSearch)) {
        Write-Host "MATCH :: Exact match." -ForegroundColor Green
        $newContent = $normalizedContent.Replace($normalizedSearch, $replaceText)
    }
    else {
        Write-Host "RETRY :: Attempting flexible whitespace match..." -ForegroundColor Yellow
        $tokens = $normalizedSearch -split '\s+' | Where-Object { $_ -ne "" }
        if ($tokens.Count -eq 0) { Write-Error "FAILURE :: Search text contains only whitespace." }
        
        $escapedTokens = $tokens | ForEach-Object { [regex]::Escape($_) }
        $flexiblePattern = $escapedTokens -join '\s+'
        $regex = [regex]::new($flexiblePattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
        
        $matchCount = $regex.Matches($normalizedContent).Count
        
        if ($matchCount -eq 0) {
            Write-Error "FAILURE :: Content not found in $targetPath"
        }
        elseif ($matchCount -gt 1) {
            Write-Error "FAILURE :: Ambiguous match - found $matchCount occurrences in $targetPath. Please make your search text more specific."
        }
        
        Write-Host "MATCH :: Flexible whitespace match found." -ForegroundColor Green
        $newContent = $regex.Replace($normalizedContent, $replaceText, 1)
    }

    # Write to disk
    $newContent | Set-Content -Path $targetPath -NoNewline -Encoding UTF8

    # Verification
    if ($pathIsGitTracked) {
        $diff = git diff --no-color --unified=0 $targetPath
        if (-not [string]::IsNullOrWhiteSpace($diff)) {
            Write-Host "SUCCESS :: File patched." -ForegroundColor Green
            Write-Host "--- GIT DIFF START ---" -ForegroundColor Gray
            Write-Host $diff
            Write-Host "--- GIT DIFF END ---" -ForegroundColor Gray
            
            if (-not [string]::IsNullOrWhiteSpace($BranchName)) {
                git add $targetPath
                git commit -m "AI Patch: Update $targetPath"
            }
        }
        else {
            Write-Warning "NO CHANGE :: Content matched but result identical."
        }
    }
}

# ---------------------------------------------------------
# 3. Cleanup Rollback Point (Success)
# ---------------------------------------------------------

if ($stashCreated) {
    git stash drop
    Write-Host "`n✅ Rollback point removed (all patches applied successfully)" -ForegroundColor Green
}