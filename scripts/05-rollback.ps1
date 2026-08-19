param([string]$Release="nexops",[int]$Revision=0)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\_common.ps1"

if (-not (HasCommand "helm")) { throw "Helm is not installed." }
if (-not (CurrentContext)) { throw "Kubernetes is not reachable." }

Write-Host "NEXOPS ROLLBACK" -ForegroundColor Yellow
Section "HISTORY"
& helm history $Release -n $Namespace

if ($Revision -le 0) { $Revision = [int](Read-Host "Enter target Helm revision") }
if ($Revision -le 0) { throw "Invalid revision." }

$answer = Read-Host "Type ROLLBACK to roll back $Release to revision $Revision"
if ($answer -cne "ROLLBACK") { Write-Host "Cancelled."; exit 0 }

& helm rollback $Release $Revision -n $Namespace --wait --timeout 180s
if ($LASTEXITCODE -ne 0) { throw "Rollback failed." }

& "$PSScriptRoot\02-verify.ps1"
