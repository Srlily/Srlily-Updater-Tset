#!/usr/bin/env pwsh
<#
.SYNOPSIS
  本地打包 Srlily Updater Test 为可分发 zip + SHA256。
.EXAMPLE
  pwsh ./tools/package.ps1 -Version 1.0.0
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [string]$Runtime = "win-x64",
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not $Version) {
    $props = Get-Content Directory.Build.props -Raw
    if ($props -match '<Version>([^<]+)</Version>') {
        $Version = $Matches[1]
    } else {
        $Version = "0.0.0"
    }
}

Write-Host "==> Packaging Srlily Updater Test v$Version ($Runtime)"

$project = "src/Srlily.UpdaterTset/Srlily.UpdaterTset.csproj"
$outDir = "publish/$Runtime"
$artifactName = "Srlily.UpdaterTset-v$Version-$Runtime"

if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $outDir, artifacts | Out-Null

dotnet publish $project `
    -c $Configuration `
    -r $Runtime `
    --self-contained true `
    -p:Version=$Version `
    -o $outDir

if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed" }

$zip = "artifacts/$artifactName.zip"
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path "$outDir/*" -DestinationPath $zip

$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
"$hash  $artifactName.zip" | Set-Content "artifacts/checksums.sha256" -Encoding ascii
Copy-Item update-manifest.json artifacts/ -Force

Write-Host "==> Done"
Write-Host "    $zip"
Write-Host "    SHA256: $hash"
