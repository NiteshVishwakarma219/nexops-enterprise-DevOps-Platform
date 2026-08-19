$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"

Write-Host "NEXOPS PLATFORM STATUS" -ForegroundColor Cyan
Info "Repository: $RepoRoot"
Info "Namespace : $Namespace"

Section "TOOLS"
foreach ($tool in @("git","docker","kubectl","helm","kind","argocd")) {
    if (HasCommand $tool) { Pass "$tool is installed" }
    else { Warn "$tool is not installed/on PATH" }
}

Section "GIT"
if (HasCommand "git") {
    & git -C $RepoRoot status --short --branch
    & git -C $RepoRoot remote -v
} else { Warn "git unavailable" }

Section "DOCKER"
if (HasCommand "docker") {
    & docker info *> $null
    if ($LASTEXITCODE -eq 0) {
        Pass "Docker daemon reachable"
        & docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    } else { Warn "Docker daemon is not running/reachable" }
}

Section "KUBERNETES"
if (HasCommand "kubectl") {
    $ctx = CurrentContext
    if ($ctx) {
        Info "Context: $ctx"
        & kubectl cluster-info
        & kubectl get nodes -o wide
        & kubectl get pods -n $Namespace -o wide
        & kubectl get svc -n $Namespace
        & kubectl get ingress -n $Namespace
    } else { Warn "No current Kubernetes context" }
} else { Warn "kubectl unavailable" }

Section "ARGO CD"
if (HasCommand "argocd") {
    & argocd app list 2>&1
    if ($LASTEXITCODE -eq 0) { Pass "Argo CD CLI query succeeded" }
    else { Warn "Argo CD CLI is installed but not authenticated/reachable" }
} else { Warn "argocd CLI unavailable" }

Section "APPLICATION"
HttpCheck $FrontendUrl | Out-Null
HttpCheck $BackendUrl | Out-Null
HttpCheck $DomainUrl | Out-Null

Write-Host ""
Write-Host "Status check finished. WARN means 'investigate', not automatically 'broken'." -ForegroundColor Yellow
