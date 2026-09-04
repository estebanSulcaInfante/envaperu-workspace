[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet('Reset', 'Update', 'Start', 'Stop', 'Status')]
    [string]$Action,

    [ValidateSet('jarra-real-6l', 'jarra-real-6l-opm-compartida', 'jarra-real-6l-pesaje-piezas')]
    [string]$Scenario = 'jarra-real-6l',

    [datetime]$Fecha = (Get-Date),
    [switch]$ConfirmReset,
    [switch]$OpenBrowser,
    [string]$PostgresHost = '127.0.0.1',
    [int]$PostgresPort = 5432,
    [string]$PostgresUser = 'postgres',
    [string]$PostgresPassword = $env:ENVA_UAT_POSTGRES_PASSWORD
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$Workspace = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$BackendDir = Join-Path $Workspace 'backend'
$FrontendDir = Join-Path $Workspace 'frontend'
$StationDir = Join-Path $Workspace 'modulo-pesaje'
$StationBackend = Join-Path $StationDir 'backend'
$StationFrontend = Join-Path $StationDir 'frontend'
$RuntimeRoot = [System.IO.Path]::GetFullPath((Join-Path $Workspace '.codex-tmp\uat-recorrido'))
$LogDir = Join-Path $RuntimeRoot 'logs'
$StationDataRoot = Join-Path $RuntimeRoot 'station'
$ProcessStateFile = Join-Path $RuntimeRoot 'processes.json'
$ScenarioStateFile = Join-Path $RuntimeRoot 'scenario.json'
$DatabaseName = 'enva_uat_recorrido'
if ([string]::IsNullOrWhiteSpace($PostgresPassword)) {
    $PostgresPassword = '1234'
}
$DatabaseUrl = "postgresql://$PostgresUser`:$PostgresPassword@$PostgresHost`:$PostgresPort/$DatabaseName"
$CentralOrigin = 'http://127.0.0.1:5100'
$FrontendOrigin = 'http://127.0.0.1:5174'
$StationOrigin = 'http://127.0.0.1:5051'
$StationCode = 'PESAJE-RECORRIDO-01'
$BackendPython = Join-Path $BackendDir '.venv\Scripts\python.exe'
$StationPython = Join-Path $StationBackend '.venv\Scripts\python.exe'
$StationMain = Join-Path $StationBackend 'station_main.py'
$StationControl = Join-Path $StationBackend 'station_control.py'

function Assert-LocalSafety {
    if ($DatabaseName -cne 'enva_uat_recorrido') {
        throw 'Guardia de seguridad: el nombre de base UAT no coincide exactamente.'
    }
    if ($PostgresHost -notin @('127.0.0.1', 'localhost', '::1')) {
        throw 'Guardia de seguridad: la base UAT debe estar en loopback.'
    }
    $expectedRoot = [System.IO.Path]::GetFullPath((Join-Path $Workspace '.codex-tmp\uat-recorrido'))
    if ($RuntimeRoot -cne $expectedRoot -or -not $RuntimeRoot.StartsWith($Workspace, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Guardia de seguridad: el almacenamiento UAT no coincide con la ruta aislada esperada.'
    }
}

function Assert-Tooling {
    foreach ($path in @($BackendPython, $StationPython, $StationMain, $StationControl)) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Falta una dependencia local requerida: $path"
        }
    }
    foreach ($command in @('dropdb.exe', 'createdb.exe', 'npm.cmd')) {
        if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
            throw "No se encontro $command en PATH."
        }
    }
}

function Ensure-FrontendDependencies {
    param(
        [string]$ProjectDir,
        [string]$ProjectLabel
    )
    $viteCommand = Join-Path $ProjectDir 'node_modules\.bin\vite.cmd'
    if (Test-Path -LiteralPath $viteCommand -PathType Leaf) { return }

    $lockFile = Join-Path $ProjectDir 'package-lock.json'
    if (-not (Test-Path -LiteralPath $lockFile -PathType Leaf)) {
        throw "Falta package-lock.json para preparar $ProjectLabel de forma reproducible."
    }

    Write-Host "Preparando dependencias de $ProjectLabel..."
    $npm = (Get-Command npm.cmd).Source
    & $npm --prefix $ProjectDir ci
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $viteCommand -PathType Leaf)) {
        throw "No se pudieron preparar las dependencias de $ProjectLabel."
    }
}

function Assert-UatDatabaseAtHead {
    $backendEnvironment = @{
        DATABASE_URL = $DatabaseUrl
        CATALOG_IMAGE_STORAGE = 'database'
        SCM_AUTH_MODE = 'local_actor'
    }
    $revisions = Set-TemporaryEnvironment -Values $backendEnvironment -Body {
        Push-Location $BackendDir
        try {
            # Alembic envia mensajes INFO por stderr aun cuando termina con
            # codigo 0. Windows PowerShell convierte ese stderr en
            # NativeCommandError si ErrorActionPreference es Stop, por lo que
            # lo capturamos temporalmente como texto y decidimos por exit code.
            $previousErrorActionPreference = $ErrorActionPreference
            try {
                $ErrorActionPreference = 'Continue'
                $currentOutput = @(
                    & $BackendPython -m flask --app app db current 2>&1 |
                        ForEach-Object { $_.ToString() }
                )
                $currentExitCode = $LASTEXITCODE
                $headOutput = @(
                    & $BackendPython -m flask --app app db heads 2>&1 |
                        ForEach-Object { $_.ToString() }
                )
                $headExitCode = $LASTEXITCODE
            }
            finally {
                $ErrorActionPreference = $previousErrorActionPreference
            }
            if ($currentExitCode -ne 0) {
                throw ($currentOutput -join [Environment]::NewLine)
            }
            if ($headExitCode -ne 0) {
                throw ($headOutput -join [Environment]::NewLine)
            }
            $currentMatch = [regex]::Match(($currentOutput -join ' '), '(?i)\b[0-9a-f]{12}\b')
            $headMatch = [regex]::Match(($headOutput -join ' '), '(?i)\b[0-9a-f]{12}\b')
            if (-not $currentMatch.Success -or -not $headMatch.Success) {
                throw 'No se pudo determinar la revision actual y el head de Alembic.'
            }
            return @($currentMatch.Value.ToLowerInvariant(), $headMatch.Value.ToLowerInvariant())
        }
        finally { Pop-Location }
    }
    if ($revisions[0] -cne $revisions[1]) {
        throw "La base UAT esta en $($revisions[0]) y el codigo exige $($revisions[1]). Ejecute '.\scripts\uat-local.ps1 Update' para migrarla sin borrar el avance."
    }
}

function Set-TemporaryEnvironment {
    param([hashtable]$Values, [scriptblock]$Body)
    $previous = @{}
    try {
        foreach ($key in $Values.Keys) {
            $previous[$key] = [System.Environment]::GetEnvironmentVariable($key, 'Process')
            [System.Environment]::SetEnvironmentVariable($key, [string]$Values[$key], 'Process')
        }
        return (& $Body)
    }
    finally {
        foreach ($key in $Values.Keys) {
            [System.Environment]::SetEnvironmentVariable($key, $previous[$key], 'Process')
        }
    }
}

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Save-JsonFile {
    param([string]$Path, [object]$Value)
    $Value | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Path -Encoding UTF8
}

function Get-OwnedProcess {
    param([int]$ProcessId, [string]$Marker)
    $item = Get-CimInstance Win32_Process -Filter "ProcessId = $ProcessId" -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $null }
    if ([string]::IsNullOrWhiteSpace($item.CommandLine) -or $item.CommandLine.IndexOf($Marker, [System.StringComparison]::OrdinalIgnoreCase) -lt 0) {
        throw "Se rehusa detener PID ${ProcessId}: su linea de comando no contiene el marcador UAT '$Marker'."
    }
    return $item
}

function Stop-OwnedProcessTree {
    param([int]$ProcessId, [string]$Marker)
    $root = Get-OwnedProcess -ProcessId $ProcessId -Marker $Marker
    if ($null -eq $root) { return }
    $all = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    $descendants = New-Object System.Collections.Generic.List[int]
    function Add-Children([int]$ParentId) {
        foreach ($child in @($all | Where-Object { $_.ParentProcessId -eq $ParentId })) {
            Add-Children -ParentId ([int]$child.ProcessId)
            $descendants.Add([int]$child.ProcessId)
        }
    }
    Add-Children -ParentId $ProcessId
    foreach ($childPid in $descendants) {
        Stop-Process -Id $childPid -Force -ErrorAction SilentlyContinue
    }
    Stop-Process -Id $ProcessId -Force -ErrorAction SilentlyContinue
}

function Stop-UatProcesses {
    $state = Read-JsonFile -Path $ProcessStateFile
    if ($null -eq $state) { return }

    if ($state.station -and (Test-Path -LiteralPath $StationControl)) {
        & $StationPython $StationControl stop --station-id $StationCode 2>$null | Out-Null
        Start-Sleep -Milliseconds 600
    }
    foreach ($name in @('station', 'frontend', 'central')) {
        $entry = $state.$name
        if ($null -ne $entry) {
            Stop-OwnedProcessTree -ProcessId ([int]$entry.pid) -Marker ([string]$entry.marker)
        }
    }
    Remove-Item -LiteralPath $ProcessStateFile -Force -ErrorAction SilentlyContinue
}

function Assert-PortFree {
    param([int]$Port)
    $listener = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue
    if ($listener) {
        throw "El puerto UAT $Port ya esta ocupado. No se detendra un proceso que no pertenezca al lanzador."
    }
}

function Wait-HttpReady {
    param([string]$Url, [int]$TimeoutSeconds = 60)
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $Url -TimeoutSec 3
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) { return }
        }
        catch { Start-Sleep -Milliseconds 500 }
    } while ((Get-Date) -lt $deadline)
    throw "El servicio no quedo listo: $Url"
}

function Start-HiddenProcess {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList,
        [string]$WorkingDirectory,
        [hashtable]$Environment,
        [string]$LogName
    )
    $stdout = Join-Path $LogDir "$LogName.out.log"
    $stderr = Join-Path $LogDir "$LogName.err.log"
    $process = Set-TemporaryEnvironment -Values $Environment -Body {
        Start-Process -FilePath $FilePath -ArgumentList $ArgumentList `
            -WorkingDirectory $WorkingDirectory -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    }
    return $process
}

function Reset-Uat {
    if (-not $ConfirmReset) {
        throw 'Reset es destructivo. Repita con -ConfirmReset; solo se eliminara enva_uat_recorrido y .codex-tmp/uat-recorrido.'
    }
    Assert-LocalSafety
    Assert-Tooling
    Ensure-FrontendDependencies -ProjectDir $FrontendDir -ProjectLabel 'la Central'
    Ensure-FrontendDependencies -ProjectDir $StationFrontend -ProjectLabel 'la estación de pesaje'
    Stop-UatProcesses
    foreach ($port in @(5100, 5174, 5051)) { Assert-PortFree -Port $port }

    if (Test-Path -LiteralPath $RuntimeRoot) {
        Remove-Item -LiteralPath $RuntimeRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $LogDir, $StationDataRoot -Force | Out-Null

    $databaseEnvironment = @{ PGPASSWORD = $PostgresPassword }
    Set-TemporaryEnvironment -Values $databaseEnvironment -Body {
        & dropdb.exe --if-exists --force --host $PostgresHost --port $PostgresPort --username $PostgresUser $DatabaseName
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo eliminar la base UAT exacta.' }
        & createdb.exe --host $PostgresHost --port $PostgresPort --username $PostgresUser --encoding UTF8 $DatabaseName
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear la base UAT exacta.' }
    }

    $backendEnvironment = @{
        DATABASE_URL = $DatabaseUrl
        SCM_AUTH_MODE = 'local_actor'
        SCM_RECEPCION_ENABLED = 'true'
        CATALOG_IMAGE_STORAGE = 'database'
        ALLOWED_ORIGINS = $FrontendOrigin
    }
    $seed = Set-TemporaryEnvironment -Values $backendEnvironment -Body {
        Push-Location $BackendDir
        try {
            & $BackendPython -m flask --app app db upgrade head
            if ($LASTEXITCODE -ne 0) { throw 'Fallaron las migraciones de la base UAT.' }
            $seedOutput = @(& $BackendPython -m flask --app app seed-uat-recorrido --confirm-local --scenario $Scenario --fecha-operativa $Fecha.ToString('yyyy-MM-dd') 2>&1)
            if ($LASTEXITCODE -ne 0) { throw ($seedOutput -join [Environment]::NewLine) }
            $jsonLine = $seedOutput | Where-Object { "$_".TrimStart().StartsWith('{') } | Select-Object -Last 1
            if (-not $jsonLine) { throw 'La semilla no devolvio su contrato JSON.' }
            return ("$jsonLine" | ConvertFrom-Json)
        }
        finally { Pop-Location }
    }
    foreach ($field in @('scenario', 'station_id', 'station_token', 'operator_id')) {
        if (-not $seed.PSObject.Properties[$field] -or [string]::IsNullOrWhiteSpace([string]$seed.$field)) {
            throw "La semilla no devolvio el campo requerido '$field'."
        }
    }

    $npm = (Get-Command npm.cmd).Source
    & $npm --prefix $FrontendDir run build
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar la interfaz de la Central.' }
    & $npm --prefix $StationFrontend run build
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar la interfaz de la estacion.' }

    $seed.station_token | & $StationPython $StationControl provision-token --data-root $StationDataRoot --token-stdin
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo aprovisionar el token DPAPI de la estacion.' }

    $safeSeed = [ordered]@{
        scenario = [string]$seed.scenario
        fecha_operativa = $Fecha.ToString('yyyy-MM-dd')
        station_id = [string]$seed.station_id
        operator_id = [int]$seed.operator_id
        actor_ids = $seed.actor_ids
        product = $seed.product
        material = $seed.material
        machine = $seed.machine
        location_codes = $seed.location_codes
        generated_at = (Get-Date).ToString('o')
    }
    if ($seed.PSObject.Properties['opening_suggestion']) {
        $safeSeed['opening_suggestion'] = $seed.opening_suggestion
    }
    if ($seed.PSObject.Properties['opm_walkthrough']) {
        $safeSeed['opm_walkthrough'] = $seed.opm_walkthrough
    }
    if ($seed.PSObject.Properties['pieces_weighing_walkthrough']) {
        $safeSeed['pieces_weighing_walkthrough'] = $seed.pieces_weighing_walkthrough
    }
    Save-JsonFile -Path $ScenarioStateFile -Value $safeSeed
    Write-Host 'RESET OK: escenario limpio y token local protegido con DPAPI.'
    Write-Host 'Siguiente paso: .\scripts\uat-local.ps1 Start'
}

function Start-Uat {
    Assert-LocalSafety
    Assert-Tooling
    Ensure-FrontendDependencies -ProjectDir $FrontendDir -ProjectLabel 'la Central'
    Ensure-FrontendDependencies -ProjectDir $StationFrontend -ProjectLabel 'la estación de pesaje'
    if (-not (Test-Path -LiteralPath $ScenarioStateFile)) {
        throw 'No existe un escenario preparado. Ejecute Reset -ConfirmReset primero.'
    }
    if (Test-Path -LiteralPath $ProcessStateFile) {
        throw 'Ya existe estado de procesos UAT. Use Status o Stop antes de iniciar otra vez.'
    }
    Assert-UatDatabaseAtHead
    foreach ($port in @(5100, 5174, 5051)) { Assert-PortFree -Port $port }
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    $scenarioState = Read-JsonFile -Path $ScenarioStateFile
    $activeScenario = if ($scenarioState.scenario) { [string]$scenarioState.scenario } else { $Scenario }
    $npm = (Get-Command npm.cmd).Source

    $central = Start-HiddenProcess -FilePath $BackendPython -WorkingDirectory $BackendDir -LogName 'central' `
        -ArgumentList @('-m', 'flask', '--app', 'run:app', 'run', '--host', '127.0.0.1', '--port', '5100', '--no-reload') `
        -Environment @{
            DATABASE_URL = $DatabaseUrl; SCM_AUTH_MODE = 'local_actor'; SCM_RECEPCION_ENABLED = 'true';
            CATALOG_IMAGE_STORAGE = 'database'; ALLOWED_ORIGINS = $FrontendOrigin; PYTHONUNBUFFERED = '1'
        }
    $frontend = Start-HiddenProcess -FilePath $npm -WorkingDirectory $FrontendDir -LogName 'frontend' `
        -ArgumentList @('run', 'dev', '--', '--host', '127.0.0.1', '--port', '5174', '--strictPort') `
        -Environment @{
            VITE_API_URL = $CentralOrigin; VITE_SCM_AUTH_MODE = 'local_actor';
            VITE_SCM_ACTOR_ID = [string]$scenarioState.actor_ids.gerencia; VITE_SCM_PROFILE_SWITCH_ENABLED = 'true';
            VITE_SCM_WEIGHING_STATION_URL = "$StationOrigin/"
        }
    $station = Start-HiddenProcess -FilePath $StationPython -WorkingDirectory $StationBackend -LogName 'station' `
        -ArgumentList @($StationMain, '--port', '5051', '--station-id', $StationCode, '--station-uuid', [string]$scenarioState.station_id,
            '--scm-operator-id', [string]$scenarioState.operator_id, '--static-dir', (Join-Path $StationFrontend 'dist'),
            '--data-root', $StationDataRoot, '--allow-scale-simulation', '--simulate-printer') `
        -Environment @{
            CENTRAL_ORIGIN = $CentralOrigin; CENTRAL_API_URL = "$CentralOrigin/api"; ALLOW_INSECURE_CENTRAL = 'false';
            STATION_MODE = 'CONNECTED_NORMALIZED'; SYNC_ENABLED = 'false'; MONITORING_ENABLED = 'true';
            ALLOW_LOCAL_SCM_DEMO = 'false';
            ALLOW_SCALE_SIMULATION = 'true'; SIMULATE_PRINTER = 'true'; STATION_APP_VERSION = '1.1.0-uat';
            PYTHONUNBUFFERED = '1'
        }

    $processes = [ordered]@{
        central = @{ pid = $central.Id; marker = '5100' }
        frontend = @{ pid = $frontend.Id; marker = '5174' }
        station = @{ pid = $station.Id; marker = $StationCode }
        started_at = (Get-Date).ToString('o')
    }
    Save-JsonFile -Path $ProcessStateFile -Value $processes
    try {
        Wait-HttpReady -Url "$CentralOrigin/api/ready" -TimeoutSeconds 60
        Wait-HttpReady -Url $FrontendOrigin -TimeoutSeconds 60
        Wait-HttpReady -Url "$StationOrigin/api/local/v1/health/ready" -TimeoutSeconds 90
    }
    catch {
        Stop-UatProcesses
        throw
    }

    Write-Host "Escenario: $activeScenario"
    if ($activeScenario -eq 'jarra-real-6l-pesaje-piezas') {
        Write-Host 'Alcance:   piezas fabricadas; materia prima y preparación excluidas'
    }
    Write-Host "Central:  $FrontendOrigin"
    Write-Host "Pesaje:   $StationOrigin"
    Write-Host "API:      $CentralOrigin/api/ready"
    if ($OpenBrowser) {
        Start-Process $FrontendOrigin
        Start-Process $StationOrigin
    }
}

function Update-Uat {
    Assert-LocalSafety
    Assert-Tooling
    Ensure-FrontendDependencies -ProjectDir $FrontendDir -ProjectLabel 'la Central'
    Ensure-FrontendDependencies -ProjectDir $StationFrontend -ProjectLabel 'la estación de pesaje'
    if (-not (Test-Path -LiteralPath $ScenarioStateFile)) {
        throw 'No existe un escenario preparado. Update nunca crea ni reinicia datos; ejecute Reset -ConfirmReset solo si realmente desea comenzar desde cero.'
    }

    # Update conserva la base y scenario.json. Solo detiene procesos que fueron
    # iniciados por este lanzador, aplica migraciones y reconstruye la estación.
    Stop-UatProcesses
    foreach ($port in @(5100, 5174, 5051)) { Assert-PortFree -Port $port }
    New-Item -ItemType Directory -Path $LogDir, $StationDataRoot -Force | Out-Null

    $backendEnvironment = @{
        DATABASE_URL = $DatabaseUrl
        SCM_AUTH_MODE = 'local_actor'
        SCM_RECEPCION_ENABLED = 'true'
        CATALOG_IMAGE_STORAGE = 'database'
        ALLOWED_ORIGINS = $FrontendOrigin
    }
    Set-TemporaryEnvironment -Values $backendEnvironment -Body {
        Push-Location $BackendDir
        try {
            & $BackendPython -m flask --app app db upgrade head
            if ($LASTEXITCODE -ne 0) {
                throw 'Fallaron las migraciones. La base UAT se conserva y los servicios quedan detenidos.'
            }
            & $BackendPython -m flask --app app seed-scm-config
            if ($LASTEXITCODE -ne 0) {
                throw 'No se pudieron actualizar roles y capacidades SCM. La base UAT se conserva y los servicios quedan detenidos.'
            }
        }
        finally { Pop-Location }
    }

    $npm = (Get-Command npm.cmd).Source
    & $npm --prefix $FrontendDir run build
    if ($LASTEXITCODE -ne 0) {
        throw 'No se pudo compilar la interfaz de la Central. La base UAT se conserva y los servicios quedan detenidos.'
    }
    & $npm --prefix $StationFrontend run build
    if ($LASTEXITCODE -ne 0) {
        throw 'No se pudo compilar la estación. La base UAT se conserva y los servicios quedan detenidos.'
    }

    Write-Host 'UPDATE OK: migraciones y aplicaciones actualizadas sin borrar documentos ni saldos.'
    Start-Uat
}

function Show-UatStatus {
    $state = Read-JsonFile -Path $ProcessStateFile
    $scenarioState = Read-JsonFile -Path $ScenarioStateFile
    $activeScenario = if ($null -ne $scenarioState -and $scenarioState.scenario) {
        [string]$scenarioState.scenario
    }
    else {
        $Scenario
    }
    Write-Host "Escenario: $activeScenario"
    if ($activeScenario -eq 'jarra-real-6l-pesaje-piezas') {
        Write-Host 'Alcance:   piezas fabricadas; materia prima y preparación excluidas'
    }
    Write-Host "Base:      $DatabaseName @ $PostgresHost`:$PostgresPort"
    foreach ($entry in @(
        @{ Name = 'Central'; Url = "$CentralOrigin/api/ready" },
        @{ Name = 'Frontend'; Url = $FrontendOrigin },
        @{ Name = 'Pesaje'; Url = "$StationOrigin/api/local/v1/health/ready" }
    )) {
        $status = 'DETENIDO'
        try {
            $response = Invoke-WebRequest -UseBasicParsing -Uri $entry.Url -TimeoutSec 2
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) { $status = 'LISTO' }
        }
        catch { }
        Write-Host ("{0,-9} {1,-8} {2}" -f $entry.Name, $status, $entry.Url)
    }
    if ($null -eq $state) { Write-Host 'No hay PIDs registrados por este lanzador.' }
}

Assert-LocalSafety
switch ($Action) {
    'Reset' { Reset-Uat }
    'Update' { Update-Uat }
    'Start' { Start-Uat }
    'Stop' {
        Stop-UatProcesses
        Write-Host 'Servicios UAT propios detenidos. La base y el escenario se conservaron.'
    }
    'Status' { Show-UatStatus }
}
