#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Generate channel.json feed for Srlily-Updater from GitHub Release assets
  or from a local artifacts directory.

.EXAMPLE
  pwsh ./tools/new-channel-feed.ps1 -Version 1.0.12 -Artifacts ./artifacts
  pwsh ./tools/new-channel-feed.ps1 -FromGitHubRelease
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [string]$AppId = "srlily-updater-tset",
    [string]$AppName = "Srlily Updater Test",
    [string]$Channel = "stable",
    [string]$Artifacts = "",
    [string]$Output = "channel.json",
    [string]$Repo = "Srlily/Srlily-Updater-Tset",
    [string]$NotesFile = "CHANGELOG.md",
    [switch]$FromGitHubRelease
)

$ErrorActionPreference = "Stop"

function Get-NotesFromChangelog([string]$path, [string]$ver) {
    if (-not (Test-Path $path)) { return "" }
    $text = Get-Content $path -Raw
    $pattern = "(?ms)^## \[([^\]]+)\][^\n]*\n(.*?)(?=^## \[|\z)"
    foreach ($m in [regex]::Matches($text, $pattern)) {
        if ($m.Groups[1].Value -eq $ver) {
            return $m.Groups[2].Value.Trim()
        }
    }
    return ""
}

$assets = @{}
$notes = ""
$notesUrl = "https://github.com/$Repo/releases"
$pubDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

if ($FromGitHubRelease) {
    $rel = Invoke-RestMethod -Headers @{ "User-Agent" = "Srlily-Updater" } `
        -Uri "https://api.github.com/repos/$Repo/releases/latest"
    if (-not $Version) { $Version = $rel.tag_name.TrimStart("v") }
    $notes = $rel.body
    $notesUrl = $rel.html_url
    $pubDate = $rel.published_at
    $sums = @{}
    foreach ($a in $rel.assets) {
        if ($a.name -match "^SHA256SUMS") {
            $sumsText = (Invoke-WebRequest -Headers @{ "User-Agent" = "Srlily-Updater" } -Uri $a.browser_download_url).Content
            foreach ($line in ($sumsText -split "`n")) {
                $line = $line.Trim()
                if ($line.Length -lt 66) { continue }
                $parts = $line -split "\s+", 2
                if ($parts.Length -eq 2) { $sums[$parts[1].Trim().TrimStart("*")] = $parts[0].ToLowerInvariant() }
            }
        }
    }
    foreach ($a in $rel.assets) {
        if ($a.name -notmatch "portable\.zip$") { continue }
        $rid = if ($a.name -match "win-arm64") { "win-arm64" } elseif ($a.name -match "win-x86") { "win-x86" } else { "win-x64" }
        $sha = $sums[$a.name]
        if (-not $sha -and $a.digest -and $a.digest.StartsWith("sha256:")) {
            $sha = $a.digest.Substring(7)
        }
        $assets[$rid] = [ordered]@{
            url      = $a.browser_download_url
            fileName = $a.name
            kind     = "portable"
            size     = $a.size
            sha256   = $sha
            signature = $null
        }
    }
}
else {
    if (-not $Version) {
        $props = Get-Content Directory.Build.props -Raw
        if ($props -match '<Version>([^<]+)</Version>') { $Version = $Matches[1] }
        else { throw "Version not specified" }
    }
    if (-not $Artifacts) { $Artifacts = "artifacts" }
    $notes = Get-NotesFromChangelog $NotesFile $Version

    foreach ($f in Get-ChildItem $Artifacts -Filter "*-portable.zip" -File) {
        $rid = if ($f.Name -match "win-arm64") { "win-arm64" } elseif ($f.Name -match "win-x86") { "win-x86" } else { "win-x64" }
        $sha = (Get-FileHash $f.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        $assets[$rid] = [ordered]@{
            url      = "https://github.com/$Repo/releases/download/v$Version/$($f.Name)"
            fileName = $f.Name
            kind     = "portable"
            size     = $f.Length
            sha256   = $sha
            signature = $null
        }
    }
}

if ($assets.Count -eq 0) { throw "No portable assets found" }

$feed = [ordered]@{
    schemaVersion = 1
    appId         = $AppId
    name          = $AppName
    channel       = $Channel
    version       = $Version
    pubDate       = $pubDate
    notes         = $notes
    notesUrl      = $notesUrl
    homepage      = "https://github.com/$Repo"
    minOs         = "windows-10"
    runtime       = "net10.0-windows"
    assets        = $assets
}

$json = $feed | ConvertTo-Json -Depth 8
Set-Content -Path $Output -Value $json -Encoding utf8
Write-Host "Wrote $Output (version=$Version, assets=$($assets.Keys -join ','))"
