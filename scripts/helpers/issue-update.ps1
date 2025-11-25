# issue-update.ps1
# Helper to update GitHub issues
# Input: { "issue_number": 1, "action": "progress|complete", "comment": "..." }
# Output: { "success": true, "issue_url": "..." }

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
if (-not $input.issue_number) {
    throw "Missing required param: issue_number"
}

$issueNum = $input.issue_number
$action = $input.action ?? "progress"
$comment = $input.comment ?? ""

# Build comment based on action
$emoji = switch ($action) {
    "start" { "🚀" }
    "progress" { "⚡" }
    "complete" { "✅" }
    "block" { "🚧" }
    default { "📝" }
}

$fullComment = "$emoji $comment"

# Post comment
$result = gh issue comment $issueNum --body $fullComment 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "Failed to update issue: $result"
}

# Get issue URL
$issueUrl = gh issue view $issueNum --json url --jq '.url' 2>&1

# Output
@{
    success   = $true
    issue_url = $issueUrl
    action    = $action
} | ConvertTo-Json -Compress
