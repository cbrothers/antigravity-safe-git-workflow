<#
.SYNOPSIS
    Antigravity Cache Client - Redis-backed context store

.DESCRIPTION
    Provides a simple interface to the Redis cache server for
    storing/retrieving compressed commands, context, and analysis.

.EXAMPLE
    . .\scripts\Connect-Cache.ps1
    cache set "cmd:status" "git status && git log -3 --oneline"
    cache get "cmd:status"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ConfigFile = ".agent\cache-config.json"
)

$ErrorActionPreference = "Stop"

# Load configuration
if (-not (Test-Path $ConfigFile)) {
    $config = @{
        Host     = "10.10.1.53"
        Port     = 6379
        Password = "AntigravityCache2024!"
    }
    $config | ConvertTo-Json | Set-Content $ConfigFile
    Write-Host "✅ Created cache config: $ConfigFile" -ForegroundColor Green
}
else {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
}

# Use local redis-cli from tools folder
$script:RedisCliPath = Join-Path $PSScriptRoot "..\tools\redis\redis-cli.exe"

if (-not (Test-Path $script:RedisCliPath)) {
    Write-Host "❌ redis-cli not found at $script:RedisCliPath" -ForegroundColor Red
    Write-Host "Downloading Redis CLI..." -ForegroundColor Yellow
    
    $toolsDir = Join-Path $PSScriptRoot "..\tools\redis"
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
    
    $zipPath = "$env:TEMP\redis.zip"
    Invoke-WebRequest -Uri "https://github.com/microsoftarchive/redis/releases/download/win-3.0.504/Redis-x64-3.0.504.zip" -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $toolsDir -Force
    Remove-Item $zipPath
    
    Write-Host "✅ Redis CLI downloaded" -ForegroundColor Green
}

# Create cache helper function
function Invoke-CacheCommand {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('set', 'get', 'del', 'keys', 'hset', 'hget', 'hgetall', 'ping')]
        [string]$Command,
        
        [Parameter(Mandatory = $false, Position = 1)]
        [string]$Key,
        
        [Parameter(Mandatory = $false, Position = 2)]
        [string]$Value,
        
        [Parameter(Mandatory = $false)]
        [string]$Field
    )
    
    $redisArgs = @(
        "-h", $config.Host,
        "-p", $config.Port,
        "-a", $config.Password
    )
    
    switch ($Command.ToLower()) {
        'ping' {
            $redisArgs += "PING"
        }
        'set' {
            if (-not $Key -or -not $Value) {
                throw "SET requires Key and Value"
            }
            $redisArgs += @("SET", $Key, $Value)
        }
        'get' {
            if (-not $Key) {
                throw "GET requires Key"
            }
            $redisArgs += @("GET", $Key)
        }
        'del' {
            if (-not $Key) {
                throw "DEL requires Key"
            }
            $redisArgs += @("DEL", $Key)
        }
        'keys' {
            $pattern = if ($Key) { $Key } else { "*" }
            $redisArgs += @("KEYS", $pattern)
        }
        'hset' {
            if (-not $Key -or -not $Field -or -not $Value) {
                throw "HSET requires Key, Field, and Value"
            }
            $redisArgs += @("HSET", $Key, $Field, $Value)
        }
        'hget' {
            if (-not $Key -or -not $Field) {
                throw "HGET requires Key and Field"
            }
            $redisArgs += @("HGET", $Key, $Field)
        }
        'hgetall' {
            if (-not $Key) {
                throw "HGETALL requires Key"
            }
            $redisArgs += @("HGETALL", $Key)
        }
    }
    
    & $script:RedisCliPath $redisArgs 2>&1 | Where-Object { $_ -notmatch "Warning: Using a password" }
}

# Create global alias
Set-Alias -Name cache -Value Invoke-CacheCommand -Scope Global

Write-Host "✅ Connected to Antigravity Cache" -ForegroundColor Green
Write-Host "   Host: $($config.Host):$($config.Port)" -ForegroundColor Gray
Write-Host ""
Write-Host "Usage:" -ForegroundColor Cyan
Write-Host "  cache ping" -ForegroundColor White
Write-Host "  cache set 'cmd:status' 'git status && git log -3'" -ForegroundColor White
Write-Host "  cache get 'cmd:status'" -ForegroundColor White
Write-Host "  cache keys 'cmd:*'" -ForegroundColor White
Write-Host ""

# Test connection
$script:CacheAvailable = $false
try {
    $result = Invoke-CacheCommand -Command ping
    if ($result -eq "PONG") {
        Write-Host "🎉 Cache is online!" -ForegroundColor Green
        $script:CacheAvailable = $true
    }
}
catch {
    Write-Host "⚠️  Redis cache unavailable: $_" -ForegroundColor Yellow
    Write-Host "   Falling back to .agent/memory.md for shorthand lookups" -ForegroundColor Gray
    $script:CacheAvailable = $false
}

# Fallback: Read from .agent/memory.md if cache is down
if (-not $script:CacheAvailable) {
    $memoryFile = ".agent\memory.md"
    if (Test-Path $memoryFile) {
        Write-Host "✅ Using local memory file: $memoryFile" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  No fallback available. Create .agent\memory.md for offline shorthand." -ForegroundColor Yellow
    }
}

