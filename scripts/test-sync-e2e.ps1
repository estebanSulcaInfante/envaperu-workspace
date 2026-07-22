[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspace = Split-Path -Parent $PSScriptRoot
$python = Join-Path $workspace "backend\.venv\Scripts\python.exe"

if (-not (Test-Path -LiteralPath $python)) {
    throw "Backend test environment is missing. Run scripts/bootstrap-tests.ps1 first."
}

& $python (Join-Path $PSScriptRoot "test-sync-e2e.py")
if ($LASTEXITCODE -ne 0) {
    throw "Isolated sync E2E failed with exit code $LASTEXITCODE."
}
