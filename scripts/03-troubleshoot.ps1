param(
    [string]$Pod = "",
    [string]$Container = "",
    [switch]$Logs
)
$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"

Write-Host "NEXOPS TROUBLESHOOTING REPORT (READ ONLY)" -ForegroundColor Cyan
if (-not (HasCommand "kubectl")) { Fail "kubectl is not installed"; exit 1 }
if (-not (CurrentContext)) { Fail "No Kubernetes context"; exit 1 }

Section "CONTEXT / NODES"
& kubectl config current-context
& kubectl cluster-info
& kubectl get nodes -o wide

Section "NEXOPS RESOURCES"
& kubectl get pods -n $Namespace -o wide
& kubectl get deployments -n $Namespace
& kubectl get replicasets -n $Namespace
& kubectl get svc -n $Namespace
& kubectl get ingress -n $Namespace

Section "RECENT EVENTS"
& kubectl get events -n $Namespace --sort-by=.lastTimestamp

Section "POD DETAILS"
if ($Pod) {
    & kubectl describe pod $Pod -n $Namespace
} else {
    $names = @(& kubectl get pods -n $Namespace --no-headers 2>$null | ForEach-Object {
        $x = $_ -split '\s+'
        if ($x.Count -gt 0) { $x[0] }
    })
    foreach ($name in $names) {
        Write-Host ""
        Info "describe pod: $name"
        & kubectl describe pod $name -n $Namespace
    }
}

if ($Logs) {
    Section "LOGS"
    if ($Pod) {
        if ($Container) { & kubectl logs $Pod -n $Namespace -c $Container --tail=200 }
        else { & kubectl logs $Pod -n $Namespace --all-containers=true --tail=200 }
    } else {
        Warn "Use -Pod POD_NAME -Logs for logs."
    }
}

Section "ARGO CD"
if (HasCommand "argocd") { & argocd app list 2>&1 }
else { Warn "argocd CLI unavailable" }

Write-Host ""
Pass "Troubleshooting report completed; no destructive command was executed."
