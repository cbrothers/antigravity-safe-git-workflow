# PowerShell wrapper for GitHub CLI (gh.exe)
# Usage: ./scripts/gh-wrapper.ps1 <gh arguments>
# This script forwards all arguments to the actual gh.exe binary.
# It can be whitelisted in Antigravity settings to bypass prompts.

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    $Args
)

# Resolve the path to gh.exe (assumes it's in the system PATH or default install location)
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $ghPath)) {
    # Fallback to searching in PATH
    $ghPath = (Get-Command gh.exe -ErrorAction SilentlyContinue).Source
    if (-not $ghPath) {
        Write-Error "gh.exe not found. Please ensure GitHub CLI is installed."
        exit 1
    }
}

# Execute gh with the provided arguments
& $ghPath @Args
$exitCode = $LASTEXITCODE
exit $exitCode
