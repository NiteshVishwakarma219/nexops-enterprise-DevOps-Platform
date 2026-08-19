param([string]$Domain="")
$ErrorActionPreference = "Continue"
. "$PSScriptRoot\_common.ps1"
if ($Domain) { $DomainUrl = $Domain }
Write-Host "NEXOPS DOMAIN / HTTPS CHECK" -ForegroundColor Cyan
try { $uri = [Uri]$DomainUrl; $hostName = $uri.DnsSafeHost }
catch { Fail "Invalid URL: $DomainUrl"; exit 1 }

Section "DNS"
try {
    Resolve-DnsName $hostName -ErrorAction Stop | Format-Table Name,Type,IPAddress,NameHost -AutoSize
    Pass "DNS lookup succeeded for $hostName"
} catch { Fail "DNS lookup failed for $hostName" }

Section "HTTPS"
HttpCheck $DomainUrl | Out-Null

Section "INGRESS"
if (HasCommand "kubectl") { & kubectl get ingress -A -o wide }
else { Warn "kubectl unavailable." }
Pass "Domain check completed."
