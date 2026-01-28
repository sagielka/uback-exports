$ErrorActionPreference = "Stop"

$RepoDir   = "C:\git\uback-exports"
$SourceDir = "X:\ERP\U-BACKexportFiles"
$TargetDir = Join-Path $RepoDir "generated_txt"

if (!(Test-Path $SourceDir)) {
    throw "Source path not found: $SourceDir"
}

Set-Location $RepoDir

git checkout main
git pull --rebase

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

robocopy $SourceDir $TargetDir *.txt /MIR /R:1 /W:2 /NFL /NDL /NP | Out-Null

git add -A

$changes = git diff --staged --name-only
if ([string]::IsNullOrWhiteSpace($changes)) {
    Write-Output "No changes detected."
    exit 0
}

git config user.name "windows-erp-bot"
git config user.email "windows-erp-bot@users.noreply.github.com"

$ts = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
git commit -m "Auto: ERP txt export $ts"
git push
