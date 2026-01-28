$ErrorActionPreference = "Stop"

$RepoDir   = "C:\git\uback-exports"
$SourceDir = "\\nogadc\noga\ERP\U-BACKexportFiles"
$TargetDir = Join-Path $RepoDir "generated_txt"

cmd /c "net use \\nogadc\noga /persistent:no" | Out-Null

if (!(Test-Path $SourceDir)) { throw "SourceDir not found: $SourceDir" }


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
