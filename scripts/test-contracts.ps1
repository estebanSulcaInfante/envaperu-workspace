[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspace = Split-Path -Parent $PSScriptRoot
$canonicalDir = Join-Path $workspace "contracts\sync-pesajes-legacy-v1"
$componentDirs = @(
    (Join-Path $workspace "backend\contracts\sync-pesajes-legacy-v1"),
    (Join-Path $workspace "modulo-pesaje\backend\contracts\sync-pesajes-legacy-v1")
)
$contractFiles = @("contract.schema.json", "examples.json")

foreach ($filename in $contractFiles) {
    $canonicalPath = Join-Path $canonicalDir $filename
    $canonicalHash = (Get-FileHash -LiteralPath $canonicalPath -Algorithm SHA256).Hash

    foreach ($componentDir in $componentDirs) {
        $componentPath = Join-Path $componentDir $filename
        if (-not (Test-Path -LiteralPath $componentPath)) {
            throw "Missing contract copy: $componentPath"
        }

        $componentHash = (Get-FileHash -LiteralPath $componentPath -Algorithm SHA256).Hash
        if ($componentHash -ne $canonicalHash) {
            throw "Contract drift detected: $componentPath"
        }
    }
}

$backendPython = Join-Path $workspace "backend\.venv\Scripts\python.exe"
$weighingPython = Join-Path $workspace "modulo-pesaje\backend\.venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $backendPython) -or -not (Test-Path -LiteralPath $weighingPython)) {
    throw "Test environments are missing. Run scripts/bootstrap-tests.ps1 first."
}

Write-Host "==> Backend provider contract"
Push-Location (Join-Path $workspace "backend")
try {
    & $backendPython -m pytest tests/test_sync_contract.py -q
    if ($LASTEXITCODE -ne 0) {
        throw "Backend contract test failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

Write-Host "==> Weighing consumer contract"
Push-Location (Join-Path $workspace "modulo-pesaje\backend")
try {
    & $weighingPython -m pytest tests/test_sync_contract.py -q
    if ($LASTEXITCODE -ne 0) {
        throw "Weighing contract test failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

Write-Host "Contract copies and implementations match legacy-v1."
