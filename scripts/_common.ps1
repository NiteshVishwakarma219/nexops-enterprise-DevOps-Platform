Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Namespace = if ($env:NEXOPS_NAMESPACE) { $env:NEXOPS_NAMESPACE } else { "nexops" }
$FrontendUrl = if ($env:NEXOPS_FRONTEND_URL) { $env:NEXOPS_FRONTEND_URL } else { "http://localhost:8080" }
$BackendUrl = if ($env:NEXOPS_BACKEND_URL) { $env:NEXOPS_BACKEND_URL } else { "http://localhost:8000" }
$DomainUrl = if ($env:NEXOPS_DOMAIN) { $env:NEXOPS_DOMAIN } else { "https://www.nitesh.shop" }

function Section([string]$s) {
    Write-Host ""
    Write-Host ("=" * 70) -ForegroundColor DarkGray
    Write-Host $s -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor DarkGray
}
function Pass([string]$s) { Write-Host "[PASS] $s" -ForegroundColor Green }
function Warn([string]$s) { Write-Host "[WARN] $s" -ForegroundColor Yellow }
function Fail([string]$s) { Write-Host "[FAIL] $s" -ForegroundColor Red }
function Info([string]$s) { Write-Host "[INFO] $s" -ForegroundColor Gray }

function HasCommand([string]$name) {
    return $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}
function CurrentContext {
    if (-not (HasCommand "kubectl")) { return "" }
    try { return (& kubectl config current-context 2>$null).Trim() } catch { return "" }
}
function HttpCheck([string]$url) {
    try {
        $r = Invoke-WebRequest -Uri $url -Method Get -TimeoutSec 10 -UseBasicParsing
        Pass "$url -> HTTP $([int]$r.StatusCode)"
        return $true
    } catch {
        Warn "$url -> not reachable: $($_.Exception.Message)"
        return $false
    }
}
