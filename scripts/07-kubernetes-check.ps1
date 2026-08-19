$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"
Write-Host "NEXOPS KUBERNETES CHECK" -ForegroundColor Cyan
if (-not (HasCommand "kubectl")) { Fail "kubectl unavailable"; exit 1 }
Section "CONTEXT"
& kubectl config get-contexts
& kubectl config current-context
Section "CLUSTER"
& kubectl cluster-info
Section "NODES"
& kubectl get nodes -o wide
Section "NAMESPACES"
& kubectl get ns
Section "NEXOPS"
& kubectl get pods -n $Namespace -o wide
& kubectl get deployments -n $Namespace
& kubectl get svc -n $Namespace
& kubectl get ingress -n $Namespace
Section "SECRETS (NAMES ONLY)"
& kubectl get secrets -n $Namespace
Section "EVENTS"
& kubectl get events -n $Namespace --sort-by=.lastTimestamp
Pass "Kubernetes check completed."
