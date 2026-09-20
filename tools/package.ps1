#!/usr/bin/env pwsh
<#
.SYNOPSIS
  本地打包 Srlily Updater Test：
    - portable.zip（更新器就地更新用）
    - setup.exe（Inno Setup，可选）
    - .msi（WiX 5，可选）

.EXAMPLE
  pwsh ./tools/package.ps1
  pwsh ./tools/package.ps1 -Version 1.0.1 -Runtimes win-x64,win-arm64
  pwsh ./tools/package.ps1 -IncludeInstallers
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [string[]]$Runtimes = @("win-x64"),
    [string]$Configuration = "Release",
    [switch]$IncludeInstallers,
    [switch]$SelfContained = $true
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

function Get-WixArch([string]$rid) {
    switch ($rid) {
        "win-x64"   { "x64" }
        "win-arm64" { "arm64" }
        "win-x86"   { "x86" }
        default     { "x64" }
    }
}

function Find-Iscc {
    $candidates = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe"
    )
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    $cmd = Get-Command iscc -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

$project = "src/Srlily.UpdaterTset/Srlily.UpdaterTset.csproj"
New-Item -ItemType Directory -Force -Path artifacts | Out-Null

$allHashes = @()

foreach ($rid in $Runtimes) {
    Write-Host "==> Publish $rid v$Version"
    $outDir = "publish/$rid"
    if (Test-Path $outDir) { Remove-Item $outDir -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null

    $publishArgs = @(
        $project, "-c", $Configuration, "-r", $rid,
        "--self-contained", ($SelfContained.ToString().ToLowerInvariant()),
        "-p:Version=$Version",
        "-p:PublishReadyToRun=true",
        "-o", $outDir
    )
    dotnet publish @publishArgs
    if ($LASTEXITCODE -ne 0) { throw "dotnet publish failed for $rid" }

    $base = "Srlily.UpdaterTset-v$Version-$rid"

    # 1) portable zip — primary updater package
    $zip = "artifacts/$base-portable.zip"
    if (Test-Path $zip) { Remove-Item $zip -Force }
    Compress-Archive -Path "$outDir/*" -DestinationPath $zip
    $zh = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLowerInvariant()
    $allHashes += "$zh  $base-portable.zip"
    Write-Host "    zip  $zip ($zh)"

    # 2) setup.exe (Inno Setup)
    if ($IncludeInstallers) {
        $iscc = Find-Iscc
        if (-not $iscc) {
            Write-Warning "ISCC not found; skip setup.exe. Install Inno Setup 6."
        } else {
            $setupOut = "artifacts/$base-setup.exe"
            if (Test-Path $setupOut) { Remove-Item $setupOut -Force }
            & $iscc "installer\Setup.iss" `
                "/DAppVersion=$Version" `
                "/DAppArch=$rid" `
                "/DPublishDir=..\publish\$rid" `
                "/O..$([IO.Path]::DirectorySeparatorChar)artifacts" `
                "/F$base-setup"
            if ($LASTEXITCODE -ne 0) { throw "iscc failed for $rid" }
            $sh = (Get-FileHash $setupOut -Algorithm SHA256).Hash.ToLowerInvariant()
            $allHashes += "$sh  $base-setup.exe"
            Write-Host "    exe  $setupOut ($sh)"
        }

        # 3) MSI (WiX 5 — pin version; v7 needs OSMF EULA)
        $wix = Get-Command wix -ErrorAction SilentlyContinue
        if (-not $wix) {
            Write-Host "    installing WiX 5.0.2..."
            dotnet tool install --global wix --version 5.0.2 | Out-Null
            if ($LASTEXITCODE -ne 0) { Write-Warning "wix install failed; skip MSI"; $wix = $null }
            else { $wix = Get-Command wix -ErrorAction SilentlyContinue }
        }

        if ($wix) {
            $wixArch = Get-WixArch $rid
            $msi = "artifacts/$base.msi"
            if (Test-Path $msi) { Remove-Item $msi -Force }
            $pubAbs = (Resolve-Path $outDir).Path
            $astAbs = (Resolve-Path "src/Srlily.UpdaterTset/Assets").Path
            wix build "installer/Package.wxs" `
                -d "PublishDir=$pubAbs" `
                -d "AssetsDir=$astAbs" `
                -d ProductVersion=$Version `
                -arch $wixArch `
                -o $msi
            if ($LASTEXITCODE -ne 0) { throw "wix build failed for $rid" }
            $mh = (Get-FileHash $msi -Algorithm SHA256).Hash.ToLowerInvariant()
            $allHashes += "$mh  $base.msi"
            Write-Host "    msi  $msi ($mh)"
        }
    }

    # per-arch latest.json copy
    $manifest = Get-Content latest.json -Raw | ConvertFrom-Json
    $manifest.version = $Version
    $manifest.releases.downloadPattern = "Srlily.UpdaterTset-v{version}-$rid-portable.zip"
    $manifest.releases.assetName = "Srlily.UpdaterTset-v{version}-$rid-portable.zip"
    $manifest.releases.defaultRid = $rid
    $manifest.checksum.file = "SHA256SUMS.txt"
    $manifest | ConvertTo-Json -Depth 20 | Set-Content "artifacts/latest-$rid.json" -Encoding utf8
}

Copy-Item latest.json artifacts/latest.json -Force
$allHashes | Set-Content artifacts/SHA256SUMS.txt -Encoding ascii

Write-Host "==> Done"
Get-ChildItem artifacts | Format-Table Name, Length
