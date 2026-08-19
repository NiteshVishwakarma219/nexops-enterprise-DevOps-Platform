param(
    [switch]$Build,
    [switch]$Push,
    [switch]$HelmUpgrade,
    [switch]$Wait
)
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\_common.ps1"

Write-Host "NEXOPS CONTROLLED DEPLOYMENT" -ForegroundColor Cyan
Info "No delete/destroy/uninstall command is used."

if (-not (Test-Path (Join-Path $RepoRoot ".git"))) {
    throw "Run from the enterprise-devops-platform-final repository."
}
if (-not (HasCommand "kubectl") -or -not (CurrentContext)) {
    throw "Kubernetes is not configured/reachable."
}

Section "GIT"
& git -C $RepoRoot status --short --branch

if ($Build) {
    Section "DOCKER BUILD"
    if (-not (HasCommand "docker")) { throw "Docker is not installed." }
    Info "Build command is intentionally explicit."
    & docker build -t cloudwithnitesh/nexops-backend:1.0.0 .
    if ($LASTEXITCODE -ne 0) { throw "Docker build failed." }
} else {
    Info "Docker build skipped. Use -Build intentionally."
}

if ($Push) {
    Section "DOCKER PUSH"
    if (-not (HasCommand "docker")) { throw "Docker is not installed." }
    $answer = Read-Host "Push cloudwithnitesh/nexops-backend:1.0.0? Type YES"
    if ($answer -cne "YES") { throw "Push cancelled." }
    & docker push cloudwithnitesh/nexops-backend:1.0.0
    if ($LASTEXITCODE -ne 0) { throw "Docker push failed." }
} else {
    Info "Docker push skipped. Use -Push intentionally."
}

Section "HELM"
if (HasCommand "helm") { & helm list -n $Namespace }
else { Warn "Helm unavailable." }

if ($HelmUpgrade) {
    if (-not (HasCommand "helm")) { throw "Helm is not installed." }
    $chart = Join-Path $RepoRoot "helm\nexops"
    if (-not (Test-Path $chart)) { throw "Helm chart not found at $chart" }
    $answer = Read-Host "Run helm upgrade --install for $chart? Type YES"
    if ($answer -cne "YES") { throw "Helm upgrade cancelled." }
    & helm upgrade --install nexops $chart -n $Namespace --create-namespace
    if ($LASTEXITCODE -ne 0) { throw "Helm upgrade failed." }
} else {
    Info "Helm upgrade skipped. For Argo CD/GitOps, prefer commit -> push -> Argo CD sync."
}

Section "VERIFY"
& "$PSScriptRoot\02-verify.ps1"
if ($LASTEXITCODE -ne 0) { Warn "Verification found hard failures; inspect the output above." }

if ($Wait) {
    Section "ROLLOUT"
    & kubectl rollout status deployment --all -n $Namespace --timeout=180s
    if ($LASTEXITCODE -ne 0) { throw "Rollout did not complete successfully." }
}
Pass "Controlled deployment workflow completed."
