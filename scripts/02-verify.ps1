$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"
$hardFailures = 0

function Check([string]$name, [scriptblock]$test) {
    try {
        if (& $test) { Pass $name }
        else { Fail $name; $script:hardFailures++ }
    } catch {
        Fail "$name : $($_.Exception.Message)"
        $script:hardFailures++
    }
}

Write-Host "NEXOPS VERIFICATION" -ForegroundColor Cyan

Section "GIT"
Check "Git repository exists" { Test-Path (Join-Path $RepoRoot ".git") }
if (HasCommand "git") {
    & git -C $RepoRoot status --short --branch
    $up = (& git -C $RepoRoot rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>$null).Trim()
    if ($up) {
        & git -C $RepoRoot fetch --quiet
        $ahead = [int]((& git -C $RepoRoot rev-list --count "@{u}..HEAD").Trim())
        $behind = [int]((& git -C $RepoRoot rev-list --count "HEAD..@{u}").Trim())
        if ($ahead -eq 0 -and $behind -eq 0) { Pass "Local branch matches $up" }
        else { Warn "Local/upstream differ: ahead=$ahead, behind=$behind" }
    } else { Warn "No upstream tracking branch" }
}

Section "KUBERNETES"
if (HasCommand "kubectl") {
    $ctx = CurrentContext
    if ($ctx) {
        Info "Context: $ctx"
        & kubectl cluster-info *> $null
        Check "Kubernetes API reachable" { $LASTEXITCODE -eq 0 }
        & kubectl get namespace $Namespace *> $null
        Check "Namespace '$Namespace' exists" { $LASTEXITCODE -eq 0 }
        & kubectl get nodes
        & kubectl get pods -n $Namespace -o wide
        & kubectl get deployments -n $Namespace
        & kubectl get svc -n $Namespace
        & kubectl get ingress -n $Namespace
    } else {
        Fail "No Kubernetes context"
        $hardFailures++
    }
} else { Warn "kubectl unavailable" }

Section "HELM"
if (HasCommand "helm") { & helm list -A }
else { Warn "helm unavailable" }

Section "ARGO CD"
if (HasCommand "argocd") {
    & argocd app list 2>&1
    if ($LASTEXITCODE -eq 0) { Pass "Argo CD CLI reachable" }
    else { Warn "Argo CD CLI not logged in/reachable" }
} else { Warn "argocd unavailable" }

Section "URLS"
HttpCheck $FrontendUrl | Out-Null
HttpCheck $BackendUrl | Out-Null
HttpCheck $DomainUrl | Out-Null

Section "RESULT"
if ($hardFailures -eq 0) {
    Pass "No hard failures detected"
    exit 0
} else {
    Fail "$hardFailures hard check(s) detected"
    exit 1
}
