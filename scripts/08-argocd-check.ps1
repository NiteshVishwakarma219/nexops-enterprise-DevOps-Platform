$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"
Write-Host "NEXOPS ARGO CD CHECK" -ForegroundColor Cyan
if (HasCommand "argocd") {
    Section "ARGO CD CLI"
    & argocd app list 2>&1
    if ($LASTEXITCODE -eq 0) { Pass "Argo CD CLI query succeeded." }
    else { Warn "Argo CD CLI is not logged in/reachable." }
} else { Warn "argocd CLI unavailable." }

if (HasCommand "kubectl") {
    Section "ARGO CD KUBERNETES RESOURCES"
    & kubectl get applications.argoproj.io -A 2>&1
}
Pass "Argo CD check completed."
