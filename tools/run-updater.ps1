#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Use Srlily-Updater against this test application.

.DESCRIPTION
  Finds Updater.exe (env SRLILY_UPDATER, sibling Srlily-Updater\dist, or --updater),
  points it at a host install directory that contains updater.config.json + latest.json.

.EXAMPLE
  # Check for updates on an installed copy
  pwsh ./tools/run-updater.ps1 -InstallRoot C:\Apps\SrlilyUpdaterTest -Mode check

.EXAMPLE
  # Silent apply
  pwsh ./tools/run-updater.ps1 -InstallRoot C:\Apps\SrlilyUpdaterTest -Mode apply

.EXAMPLE
  # Open updater UI
  pwsh ./tools/run-updater.ps1 -InstallRoot C:\Apps\SrlilyUpdaterTest -Mode ui
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InstallRoot,

    [ValidateSet("check", "apply", "silent", "ui")]
    [string]$Mode = "check",

    [string]$Updater = "",
    [string]$Feed = "",
    [string]$Channel = ""
)

$ErrorActionPreference = "Stop"

function Resolve-Updater([string]$explicit) {
    $candidates = @()
    if ($explicit) { $candidates += $explicit }
    if ($env:SRLILY_UPDATER) { $candidates += $env:SRLILY_UPDATER }

    $repoRoot = Split-Path -Parent $PSScriptRoot
    $candidates += @(
        (Join-Path $repoRoot "updater\Updater.exe"),
        (Join-Path $repoRoot "tools\Updater.exe"),
        (Join-Path $repoRoot "tools\updater\Updater.exe"),
        "E:\Github\Srlily-Updater\dist\Updater.exe"
    )

    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return (Resolve-Path $c).Path }
    }
    return $null
}

if (-not (Test-Path $InstallRoot)) {
    throw "InstallRoot not found: $InstallRoot"
}
$InstallRoot = (Resolve-Path $InstallRoot).Path

$updaterExe = Resolve-Updater $Updater
if (-not $updaterExe) {
    throw @"
Updater.exe not found.
Build it from Srlily-Updater, or set:
  `$env:SRLILY_UPDATER = 'E:\Github\Srlily-Updater\dist\Updater.exe'
Or copy Updater.exe to this repo under tools\Updater.exe
"@
}

$hasConfig = Test-Path (Join-Path $InstallRoot "updater.config.json")
$hasIdentity = Test-Path (Join-Path $InstallRoot "latest.json")
if (-not $hasConfig -and -not $hasIdentity) {
    Write-Warning "InstallRoot is missing updater.config.json and latest.json — updater may fail to resolve feed/version."
}

$argList = @()
switch ($Mode) {
    "check"  { $argList += @("--check", "--root", $InstallRoot) }
    "apply"  { $argList += @("--apply", "--root", $InstallRoot) }
    "silent" { $argList += @("--silent", "--root", $InstallRoot) }
    "ui"     { $argList += @("--root", $InstallRoot) }
}

if ($Feed)    { $argList += @("--feed", $Feed) }
if ($Channel) { $argList += @("--channel", $Channel) }

Write-Host "Updater : $updaterExe"
Write-Host "Target  : $InstallRoot"
Write-Host "Mode    : $Mode"
Write-Host "Args    : $($argList -join ' ')"
Write-Host ""

$p = Start-Process -FilePath $updaterExe -ArgumentList $argList -NoNewWindow -PassThru -Wait
$code = $p.ExitCode
Write-Host ""
Write-Host "exit code: $code"
Write-Host "0 = up-to-date / success"
Write-Host "10 = update available (check)"
Write-Host "20 = updated"
Write-Host "2/3/4/5/6 = config/network/verify/apply/cancel error"
exit $code
