## Sync Helper Scripts & Workflows to Enterprise DevOps Toolkit
# ---------------------------------------------------------------
# This PowerShell script copies the PowerShell helper scripts and the .agent workflow markdown files
# from the current MerchifAI project into a target Enterprise DevOps Toolkit repository.
#
# Usage:
#   .\sync-to-enterprise-devops-toolkit.ps1 -TargetPath "C:\Path\To\enterprise-devops-toolkit"
#
# The script will:
#   1. Verify the target path exists and is a Git repository.
#   2. Create a new branch (sync/merchifai-<timestamp>).
#   3. Copy the following items:
#        - scripts/*.ps1 (all PowerShell helper scripts)
#        - .agent/workflows/*.md (all workflow markdown files)
#   4. Stage, commit, and push the changes.
#   5. Output the branch name so you can open a PR.
#
# Prerequisites:
#   * Git must be in the system PATH.
#   * You have write permissions to the target repository.
#   * The target repo has a remote named "origin".
# ---------------------------------------------------------------
param(
    [Parameter(Mandatory = $true, HelpMessage = "Absolute path to the Enterprise DevOps Toolkit repo")]
    [string]$TargetPath
)

function Write-Log {
    param([string]$Message)
    Write-Host "[SyncScript] $Message"
}

# Resolve full path and verify
$TargetPath = Resolve-Path -Path $TargetPath -ErrorAction Stop
if (-not (Test-Path $TargetPath)) {
    Write-Error "Target path does not exist: $TargetPath"
    exit 1
}

# Ensure it's a git repo
if (-not (Test-Path (Join-Path $TargetPath ".git"))) {
    Write-Error "Target path is not a Git repository: $TargetPath"
    exit 1
}

# Create a timestamped branch name
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$branchName = "sync/merchifai-$timestamp"

# Change to target repo directory
Push-Location $TargetPath

# Fetch latest and create branch
git fetch origin
git checkout -b $branchName origin/main
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to create branch $branchName"
    Pop-Location
    exit 1
}

# Define source directories (relative to this script location)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceScripts = Join-Path $scriptDir "..\scripts"
$sourceWorkflows = Join-Path $scriptDir "..\.agent\workflows"

# Copy PowerShell helper scripts
Write-Log "Copying PowerShell helper scripts..."
Copy-Item -Path (Join-Path $sourceScripts "*.ps1") -Destination (Join-Path $TargetPath "scripts") -Force -Recurse

# Copy workflow markdown files
Write-Log "Copying workflow markdown files..."
Copy-Item -Path (Join-Path $sourceWorkflows "*.md") -Destination (Join-Path $TargetPath ".agent\workflows") -Force -Recurse

# Stage changes
git add scripts/*.ps1 .agent/workflows/*.md
if ($LASTEXITCODE -ne 0) {
    Write-Error "git add failed"
    Pop-Location
    exit 1
}

# Commit
$commitMessage = "chore: sync MerchifAI helper scripts & workflows (auto generated)"
git commit -m $commitMessage
if ($LASTEXITCODE -ne 0) {
    Write-Error "git commit failed – maybe nothing changed"
    Pop-Location
    exit 1
}

# Push branch
git push -u origin $branchName
if ($LASTEXITCODE -ne 0) {
    Write-Error "git push failed"
    Pop-Location
    exit 1
}

Pop-Location
Write-Log "Sync complete. Branch '$branchName' pushed to origin. Open a PR to merge it."
