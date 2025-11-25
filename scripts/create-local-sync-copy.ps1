## Create-Local-Sync-Copy.ps1
# ---------------------------------------------------------------
# This script creates a temporary folder inside the current MerchifAI project
# and copies all PowerShell helper scripts and .agent workflow markdown files
# into it. Use this when you want a local snapshot before moving the files
# to the real Enterprise DevOps Toolkit repository.
# ---------------------------------------------------------------

# Define paths (relative to the project root)
$ProjectRoot = (Get-Item $MyInvocation.MyCommand.Path).Directory.Parent.FullName
$SyncRoot = Join-Path $ProjectRoot "enterprise-devops-toolkit-sync"
$ScriptsSrc = Join-Path $ProjectRoot "scripts"
$WorkflowsSrc = Join-Path $ProjectRoot ".agent\workflows"

# Destination folders
$ScriptsDst = Join-Path $SyncRoot "scripts"
$WorkflowsDst = Join-Path $SyncRoot ".agent\workflows"

# Helper to create a folder if it doesn't exist (approved verb: New)
function New-Directory($Path) {
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
        Write-Host "Created folder: $Path"
    }
    else {
        Write-Host "Folder already exists: $Path"
    }
}

# Create the sync folder structure
New-Directory $SyncRoot
New-Directory $ScriptsDst
New-Directory $WorkflowsDst

# Copy PowerShell helper scripts (*.ps1)
Write-Host "Copying PowerShell helper scripts..."
Copy-Item -Path (Join-Path $ScriptsSrc "*.ps1") -Destination $ScriptsDst -Force
Write-Host "Scripts copied to $ScriptsDst"

# Copy workflow markdown files (*.md)
Write-Host "Copying workflow markdown files..."
Copy-Item -Path (Join-Path $WorkflowsSrc "*.md") -Destination $WorkflowsDst -Force
Write-Host "Workflows copied to $WorkflowsDst"

Write-Host "\nSync folder created at: $SyncRoot"
Write-Host "You can now move the contents to your Enterprise DevOps Toolkit repository."
