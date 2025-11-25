# git-commit.ps1
# Helper to commit changes with conventional commit format
# Input: { "type": "feat|fix|docs|etc", "message": "description", "files": ["file1", "file2"] }
# Output: { "success": true, "commit_hash": "abc123", "message": "..." }

param(
    [Parameter(ValueFromPipeline = $true)]
    [string]$InputJson,
    
    [Parameter()]
    [string]$InputFile
)

$ErrorActionPreference = "Stop"

# Read input
if ($InputFile) {
    $input = Get-Content $InputFile -Raw | ConvertFrom-Json
}
else {
    $input = $InputJson | ConvertFrom-Json
}

# Validate
if (-not $input.type -or -not $input.message) {
    throw "Missing required params: type, message"
}

# Stage files
if ($input.files -and $input.files.Count -gt 0) {
    foreach ($file in $input.files) {
        git add $file 2>&1 | Out-Null
    }
}
else {
    git add -A 2>&1 | Out-Null
}

# Create commit message
$commitMsg = "$($input.type): $($input.message)"
if ($input.body) {
    $commitMsg += "`n`n$($input.body)"
}
if ($input.issue) {
    $commitMsg += "`n`nCloses #$($input.issue)"
}

# Commit
git commit -m $commitMsg 2>&1 | Out-Null
$hash = git rev-parse --short HEAD

# Output
@{
    success     = $true
    commit_hash = $hash
    message     = $commitMsg
} | ConvertTo-Json -Compress
