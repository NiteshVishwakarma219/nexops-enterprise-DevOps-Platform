$ErrorActionPreference = "Stop"
$failed = 0
foreach ($file in Get-ChildItem $PSScriptRoot -Filter *.ps1) {
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $file.FullName, [ref]$tokens, [ref]$errors
    ) | Out-Null
    if ($errors.Count -eq 0) {
        Write-Host "[PASS] $($file.Name)" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $($file.Name)" -ForegroundColor Red
        $errors | ForEach-Object { Write-Host $_.Message -ForegroundColor Red }
        $failed++
    }
}
if ($failed) { exit 1 }
Write-Host "All scripts passed PowerShell parser checks." -ForegroundColor Green
