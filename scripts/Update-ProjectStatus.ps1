# Update GitHub Project Issue Status
# Usage: .\scripts\Update-ProjectStatus.ps1 -IssueNumber 26 -Status "In Progress"

param(
    [Parameter(Mandatory = $true)]
    [int]$IssueNumber,
    
    [Parameter(Mandatory = $true)]
    [ValidateSet("Backlog", "Ready", "In Progress", "Testing", "Done")]
    [string]$Status,
    
    [string]$Owner = "cbrothers",
    [string]$Repo = "merchifai"
)

$ErrorActionPreference = "Stop"

Write-Host "Updating issue #$IssueNumber to status: $Status" -ForegroundColor Cyan

# First, get the project number (you'll need to find this once)
# Run: gh project list --owner cbrothers
$projectNumber = 3  # MerchifAI Development project

# Get project ID
Write-Host "Getting project ID..." -ForegroundColor Gray
$projectData = & gh project view $projectNumber --owner $Owner --format json | ConvertFrom-Json
$projectId = $projectData.id

Write-Host "Project ID: $projectId" -ForegroundColor Gray

# Get the item ID for this issue in the project
Write-Host "Finding issue #$IssueNumber in project..." -ForegroundColor Gray
$itemsData = & gh project item-list $projectNumber --owner $Owner --format json --limit 100 | ConvertFrom-Json
$items = $itemsData.items

$item = $items | Where-Object { $_.content.number -eq $IssueNumber }

if (-not $item) {
    Write-Error "Issue #$IssueNumber not found in project"
    exit 1
}

$itemId = $item.id
Write-Host "Item ID: $itemId" -ForegroundColor Gray

# Get the Status field ID
Write-Host "Getting Status field ID..." -ForegroundColor Gray
$fieldsData = & gh project field-list $projectNumber --owner $Owner --format json | ConvertFrom-Json
$fields = $fieldsData.fields
$statusField = $fields | Where-Object { $_.name -eq "Status" }

if (-not $statusField) {
    Write-Error "Status field not found in project"
    exit 1
}

$fieldId = $statusField.id
Write-Host "Status Field ID: $fieldId" -ForegroundColor Gray

# Get the option ID for the desired status
$statusOption = $statusField.options | Where-Object { $_.name -eq $Status }

if (-not $statusOption) {
    Write-Error "Status option '$Status' not found. Available: $($statusField.options.name -join ', ')"
    exit 1
}

$optionId = $statusOption.id
Write-Host "Status Option ID: $optionId" -ForegroundColor Gray

# Update the item
Write-Host "Updating status..." -ForegroundColor Yellow
& gh project item-edit --id $itemId --field-id $fieldId --project-id $projectId --single-select-option-id $optionId

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Successfully updated issue #$IssueNumber to '$Status'" -ForegroundColor Green
}
else {
    Write-Error "Failed to update issue status"
    exit 1
}
