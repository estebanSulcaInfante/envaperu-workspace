[CmdletBinding()]
param(
    [ValidateSet("all", "backend", "frontend", "pesaje")]
    [string]$Component = "all",

    [switch]$Postgres
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$workspace = Split-Path -Parent $PSScriptRoot

function Assert-LastExitCode {
    param([string]$Step)

    if ($LASTEXITCODE -ne 0) {
        throw "$Step failed with exit code $LASTEXITCODE."
    }
}

function Resolve-ProjectPython {
    param([string]$ProjectPath)

    $candidates = @(
        (Join-Path $ProjectPath ".venv\Scripts\python.exe"),
        (Join-Path $ProjectPath "venv\Scripts\python.exe")
    )

    foreach ($candidate in $candidates) {
        if (-not (Test-Path -LiteralPath $candidate)) {
            continue
        }

        try {
            & $candidate -c "import sys; raise SystemExit(0)" 2>$null
            if ($LASTEXITCODE -eq 0) {
                return $candidate
            }
        }
        catch {
            # A stale Windows venv can retain python.exe while its base runtime is gone.
        }
    }

    throw "No runnable test environment found in $ProjectPath. Run .\scripts\bootstrap-tests.ps1 first."
}

function Resolve-Docker {
    $command = Get-Command docker.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $perUserDocker = Join-Path $env:LOCALAPPDATA "Programs\DockerDesktop\resources\bin\docker.exe"
    if (Test-Path -LiteralPath $perUserDocker) {
        $dockerBin = Split-Path -Parent $perUserDocker
        if (($env:Path -split ';') -notcontains $dockerBin) {
            $env:Path = "$dockerBin;$env:Path"
        }
        return $perUserDocker
    }

    throw "Docker Desktop was not found in PATH or in the per-user installation directory."
}

function Invoke-BackendTests {
    $projectPath = Join-Path $workspace "backend"
    $python = Resolve-ProjectPython -ProjectPath $projectPath

    Write-Host "==> Backend fast suite"
    Push-Location $projectPath
    try {
        & $python -m pytest
        Assert-LastExitCode "Backend fast suite"
    }
    finally {
        Pop-Location
    }

    if (-not $Postgres) {
        return
    }

    $docker = Resolve-Docker
    $composeFile = Join-Path $projectPath "docker-compose.test.yml"
    $previousDatabaseUrl = $env:TEST_DATABASE_URL

    Write-Host "==> Backend PostgreSQL harness"
    try {
        & $docker compose -f $composeFile up -d --wait
        Assert-LastExitCode "Starting PostgreSQL test service"

        $env:TEST_DATABASE_URL = "postgresql://envaperu_test:envaperu_test@localhost:55432/envaperu_test"
        Push-Location $projectPath
        try {
            & $python -m pytest -m postgres
            Assert-LastExitCode "Backend PostgreSQL harness"
        }
        finally {
            Pop-Location
        }
    }
    finally {
        if ($null -eq $previousDatabaseUrl) {
            Remove-Item Env:TEST_DATABASE_URL -ErrorAction SilentlyContinue
        }
        else {
            $env:TEST_DATABASE_URL = $previousDatabaseUrl
        }

        & $docker compose -f $composeFile down -v
    }
}

function Invoke-FrontendTests {
    $projectPath = Join-Path $workspace "frontend"
    $npm = Get-Command npm.cmd -ErrorAction Stop

    Write-Host "==> Frontend suite"
    Push-Location $projectPath
    try {
        # La suite comparte mocks globales y, en Windows, cuatro archivos
        # excedían el timeout cuando Vitest saturaba todos los workers.
        & $npm.Source run test:run -- --maxWorkers=2
        Assert-LastExitCode "Frontend suite"
    }
    finally {
        Pop-Location
    }
}

function Invoke-WeighingTests {
    $projectPath = Join-Path $workspace "modulo-pesaje\backend"
    $python = Resolve-ProjectPython -ProjectPath $projectPath

    Write-Host "==> Weighing backend suite"
    Push-Location $projectPath
    try {
        & $python -m pytest
        Assert-LastExitCode "Weighing backend suite"
    }
    finally {
        Pop-Location
    }
}

if ($Component -in @("all", "backend")) {
    Invoke-BackendTests
}

if ($Component -in @("all", "frontend")) {
    Invoke-FrontendTests
}

if ($Component -in @("all", "pesaje")) {
    Invoke-WeighingTests
}

Write-Host "All requested test suites passed."
