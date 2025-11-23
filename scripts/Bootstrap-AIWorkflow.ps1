<#
.SYNOPSIS
    Bootstrap-AIWorkflow.ps1 - Setup AI-assisted development workflow for any project.

.DESCRIPTION
    Copies the Smart Patch workflow, scripts, and Git configuration to a target project.
    Run this from the root of your NEW project directory.

.EXAMPLE
    cd C:\MyNewProject
    & "C:\Path\To\Bootstrap-AIWorkflow.ps1"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$SourcePath = "c:\Users\craig.brothers\Desktop\AI Code Ideas\AI Bands\The Silent Whistle"
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Bootstrapping AI Workflow..." -ForegroundColor Cyan

# ---------------------------------------------------------
# 1. Validate Environment
# ---------------------------------------------------------
if (-not (Test-Path ".git")) {
    Write-Error "This directory is not a Git repository. Run 'git init' first."
}

Write-Host "✅ Git repository detected." -ForegroundColor Green

# ---------------------------------------------------------
# 2. Create Directory Structure
# ---------------------------------------------------------
$dirs = @(
    ".agent",
    ".agent/scripts",
    ".agent/workflows",
    ".agent/tmp"
)

foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "📁 Created: $dir" -ForegroundColor Gray
    }
}

# ---------------------------------------------------------
# 3. Copy Core Files
# ---------------------------------------------------------
$filesToCopy = @{
    "$SourcePath\.agent\scripts\Apply-SmartPatch.ps1" = ".agent\scripts\Apply-SmartPatch.ps1"
    "$SourcePath\.agent\workflows\smart-edit.md"      = ".agent\workflows\smart-edit.md"
    "$SourcePath\.agent\rules.md"                     = ".agent\rules.md"
    "$SourcePath\.gitattributes"                      = ".gitattributes"
}

foreach ($source in $filesToCopy.Keys) {
    $dest = $filesToCopy[$source]
    
    if (Test-Path $source) {
        Copy-Item -Path $source -Destination $dest -Force
        Write-Host "📄 Copied: $dest" -ForegroundColor Gray
    }
    else {
        Write-Warning "Source file not found: $source"
    }
}

# ---------------------------------------------------------
# 4. Configure Git
# ---------------------------------------------------------
Write-Host "`n⚙️  Configuring Git..." -ForegroundColor Cyan

git config core.autocrlf false
git config core.eol lf

Write-Host "✅ Git configured for LF line endings." -ForegroundColor Green

# ---------------------------------------------------------
# 5. Create .gitignore additions
# ---------------------------------------------------------
$gitignoreAdditions = @"

# AI Workflow
.agent/tmp/*
!.agent/tmp/.gitkeep
*.backup_*
*.bak_*
patch.json
"@

if (Test-Path ".gitignore") {
    $existingContent = Get-Content ".gitignore" -Raw
    if ($existingContent -notlike "*AI Workflow*") {
        Add-Content -Path ".gitignore" -Value $gitignoreAdditions
        Write-Host "✅ Updated .gitignore" -ForegroundColor Green
    }
}
else {
    Set-Content -Path ".gitignore" -Value $gitignoreAdditions.TrimStart()
    Write-Host "✅ Created .gitignore" -ForegroundColor Green
}

# Create .gitkeep for tmp directory
New-Item -ItemType File -Path ".agent/tmp/.gitkeep" -Force | Out-Null

# ---------------------------------------------------------
# 6. Summary
# ---------------------------------------------------------
Write-Host "`n✨ AI Workflow Bootstrap Complete!" -ForegroundColor Green
Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "  1. Review .agent/rules.md and customize for your project" -ForegroundColor White
Write-Host "  2. Add the rules to your IDE's 'Project Rules' or 'Custom Instructions'" -ForegroundColor White
Write-Host "  3. Start using: /smart-edit workflow" -ForegroundColor White
Write-Host "`nWorkflow location: .agent/workflows/smart-edit.md" -ForegroundColor Gray
