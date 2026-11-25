<#
.SYNOPSIS
Thin PowerShell wrapper around install.sh for Windows.
#>
[CmdletBinding()]
param(
    [switch]$Global,
    [string[]]$Project = @(),
    [switch]$DryRun,
    [string]$BackupDir = "",
    [switch]$Force,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Find-GitBash {
    $candidates = @(
        "C:\Program Files\Git\bin\bash.exe",
        (Join-Path $env:LOCALAPPDATA "Programs\Git\bin\bash.exe"),
        "C:\Program Files (x86)\Git\bin\bash.exe"
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $candidate }
    }

    $gitCmd = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($gitCmd) {
        $gitRoot = Split-Path (Split-Path $gitCmd.Source -Parent) -Parent
        foreach ($rel in @("bin\bash.exe", "usr\bin\bash.exe")) {
            $p = Join-Path $gitRoot $rel
            if (Test-Path $p) { return $p }
        }
    }

    $bashCmd = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($bashCmd) { return $bashCmd.Source }
    return $null
}

$bashExe = Find-GitBash
if (-not $bashExe) {
    Write-Error "[ERROR] Git Bash (bash.exe) was not found. Install Git for Windows or run ./install.sh from Bash."
    exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$installSh = (Join-Path $scriptDir "install.sh") -replace '\\', '/'

$bashArgs = [System.Collections.Generic.List[string]]::new()
$bashArgs.Add($installSh)

if ($Help) { $bashArgs.Add("--help") }
if ($Global) { $bashArgs.Add("--global") }
foreach ($p in $Project) {
    if (-not [string]::IsNullOrWhiteSpace($p)) {
        $bashArgs.Add("--project")
        $bashArgs.Add($p)
    }
}
if ($DryRun) { $bashArgs.Add("--dry-run") }
if (-not [string]::IsNullOrWhiteSpace($BackupDir)) {
    $bashArgs.Add("--backup-dir")
    $bashArgs.Add($BackupDir)
}
if ($Force) { $bashArgs.Add("--force") }

& $bashExe @bashArgs
exit $LASTEXITCODE
