# Invoke-Helper.ps1
# Executes helper scripts with compressed JSON I/O for token efficiency

param(
    [Parameter(Mandatory = $true)]
    [string]$HelperName,
    
    [Parameter(Mandatory = $false)]
    [hashtable]$Params = @{}
)

$ErrorActionPreference = "Stop"

# Helper script path
$helperPath = Join-Path $PSScriptRoot "helpers\$HelperName.ps1"

if (-not (Test-Path $helperPath)) {
    throw "Helper script not found: $HelperName"
}

# Convert params to JSON
$inputJson = $Params | ConvertTo-Json -Compress -Depth 10

# Create temp file for large data (optional optimization)
$useTempFile = $inputJson.Length -gt 8000
if ($useTempFile) {
    $tempFile = Join-Path $PSScriptRoot "..\tmp\helper-input-$(Get-Random).json"
    $inputJson | Out-File -FilePath $tempFile -Encoding UTF8
    $result = & $helperPath -InputFile $tempFile
    Remove-Item $tempFile -ErrorAction SilentlyContinue
}
else {
    $result = $inputJson | & $helperPath
}

# Parse and return result
if ($result) {
    try {
        $resultObj = $result | ConvertFrom-Json
        return $resultObj
    }
    catch {
        # If not JSON, return raw
        return $result
    }
}
