# PowerShell test for gh-wrapper.ps1
# This script verifies that the wrapper forwards arguments correctly.
# It runs the wrapper with the '--version' argument and checks that the exit code is 0.

$wrapperPath = Join-Path $PSScriptRoot 'gh-wrapper.ps1'
if (-not (Test-Path $wrapperPath)) {
    Write-Error "Wrapper script not found at $wrapperPath"
    exit 1
}

# Execute the wrapper with a harmless command (gh --version)
& pwsh $wrapperPath --version
$exitCode = $LASTEXITCODE
if ($exitCode -ne 0) {
    Write-Error "gh-wrapper test failed with exit code $exitCode"
    exit $exitCode
}
else {
    Write-Host "gh-wrapper test passed"
    exit 0
}
