[CmdletBinding()]
param(
    [ValidateSet("all", "backend", "frontend", "pesaje")]
    [string]$Component = "all",

    [switch]$CleanFrontend,

    [string]$Python
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

function Test-RunnablePython {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }

    try {
        & $Path -c "import sys; raise SystemExit(0)" 2>$null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
}

function Resolve-BasePython {
    $candidates = @()

    if ($Python) {
        $candidates += $Python
    }

    $pythonCommand = Get-Command python.exe -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        $candidates += $pythonCommand.Source
    }

    foreach ($candidate in $candidates) {
        if (-not (Test-RunnablePython -Path $candidate)) {
            continue
        }

        & $candidate -c "import sys; raise SystemExit(0 if sys.version_info[:2] == (3, 12) else 1)"
        if ($LASTEXITCODE -eq 0) {
            return $candidate
        }
    }

    $pyLauncher = Get-Command py.exe -ErrorAction SilentlyContinue
    if ($pyLauncher) {
        & $pyLauncher.Source -3.12 -c "import sys; raise SystemExit(0 if sys.version_info[:2] == (3, 12) else 1)"
        if ($LASTEXITCODE -eq 0) {
            return @($pyLauncher.Source, "-3.12")
        }
    }

    throw "Python 3.12 was not found. Install it, add it to PATH, or pass -Python with its executable path."
}

function Install-PythonTestEnvironment {
    param(
        [string]$Name,
        [string]$ProjectPath
    )

    $venvPath = Join-Path $ProjectPath ".venv"
    $pythonPath = Join-Path $venvPath "Scripts\python.exe"

    Write-Host "==> Preparing $Name test environment"
    if (-not (Test-RunnablePython -Path $pythonPath)) {
        Push-Location $ProjectPath
        try {
            $basePython = Resolve-BasePython
            if ($basePython -is [array]) {
                & $basePython[0] $basePython[1] -m venv --clear .venv
            }
            else {
                & $basePython -m venv --clear .venv
            }
            Assert-LastExitCode "Creating $Name virtual environment"
        }
        finally {
            Pop-Location
        }
    }

    & $pythonPath -m pip install --upgrade pip
    Assert-LastExitCode "Upgrading pip for $Name"

    & $pythonPath -m pip install -r (Join-Path $ProjectPath "requirements-dev.txt")
    Assert-LastExitCode "Installing $Name test dependencies"
}

if ($Component -in @("all", "backend")) {
    Install-PythonTestEnvironment -Name "backend" -ProjectPath (Join-Path $workspace "backend")
}

if ($Component -in @("all", "frontend")) {
    $frontendPath = Join-Path $workspace "frontend"
    $nodeModulesPath = Join-Path $frontendPath "node_modules"
    $npm = Get-Command npm.cmd -ErrorAction Stop

    Push-Location $frontendPath
    try {
        if ($CleanFrontend -or -not (Test-Path -LiteralPath $nodeModulesPath)) {
            Write-Host "==> Installing frontend dependencies with npm ci"
            & $npm.Source ci
            Assert-LastExitCode "Installing frontend dependencies"
        }
        else {
            Write-Host "==> Validating existing frontend dependencies"
            & $npm.Source ls --depth=0 --silent | Out-Null
            if ($LASTEXITCODE -ne 0) {
                throw "Frontend dependencies are incomplete. Stop the frontend dev server and rerun with -CleanFrontend."
            }

            Write-Host "Frontend dependencies are complete; keeping the existing installation."
        }
    }
    finally {
        Pop-Location
    }
}

if ($Component -in @("all", "pesaje")) {
    Install-PythonTestEnvironment -Name "weighing backend" -ProjectPath (Join-Path $workspace "modulo-pesaje\backend")
}

Write-Host "Test environments are ready."
