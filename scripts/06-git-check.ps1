$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"
Write-Host "NEXOPS GIT CHECK" -ForegroundColor Cyan
if (-not (HasCommand "git")) { Fail "git unavailable"; exit 1 }

Section "STATUS"
& git -C $RepoRoot status --short --branch
Section "REMOTE"
& git -C $RepoRoot remote -v
Section "BRANCHES"
& git -C $RepoRoot branch -a
Section "RECENT COMMITS"
& git -C $RepoRoot log --oneline --decorate -10
Section "WORKFLOWS"
$wf = Join-Path $RepoRoot ".github\workflows"
if (Test-Path $wf) { Get-ChildItem $wf -File | Select-Object Name,Length,LastWriteTime }
else { Warn ".github/workflows not found" }

Section "TRIVY REFERENCE CHECK"
$matches = @(& git -C $RepoRoot grep -in "trivy" -- . 2>$null)
if ($matches.Count -eq 0) { Pass "No Trivy reference in tracked current files." }
else { Warn "Trivy references found:"; $matches }
