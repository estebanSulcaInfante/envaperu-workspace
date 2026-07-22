import os
import socket
import sqlite3
import subprocess
import sys
import time
import uuid
from pathlib import Path

import requests


WORKSPACE = Path(__file__).resolve().parents[1]
CENTRAL = WORKSPACE / "backend"
STATION = WORKSPACE / "modulo-pesaje"
CENTRAL_PYTHON = CENTRAL / ".venv" / "Scripts" / "python.exe"
STATION_PYTHON = STATION / "backend" / ".venv" / "Scripts" / "python.exe"
PROVIDER = CENTRAL / "tests" / "support" / "run_monitoring_provider.py"
STATION_MAIN = STATION / "backend" / "station_main.py"
STATION_CONTROL = STATION / "backend" / "station_control.py"
STATIC_DIR = STATION / "frontend" / "dist"


def _free_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def _start(command, cwd, env=None):
    process_env = os.environ.copy()
    process_env["PYTHONUNBUFFERED"] = "1"
    if env:
        process_env.update(env)
    return subprocess.Popen(
        [str(item) for item in command],
        cwd=cwd,
        env=process_env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
    )


def _stop(process):
    if process is None or process.poll() is not None:
        return
    process.terminate()
    try:
        process.wait(timeout=5)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait(timeout=5)


def _wait_json(url, predicate, *, headers=None, timeout=30, process=None):
    deadline = time.monotonic() + timeout
    last = None
    while time.monotonic() < deadline:
        if process is not None and process.poll() is not None:
            output = process.stdout.read() if process.stdout else ""
            raise AssertionError(
                f"Process exited with {process.returncode} while waiting for "
                f"{url}:\n{output}"
            )
        try:
            response = requests.get(url, headers=headers, timeout=1)
            if response.status_code == 200:
                body = response.json()
                last = body
                if predicate(body):
                    return body
        except requests.RequestException as exc:
            last = str(exc)
        time.sleep(0.25)
    raise AssertionError(f"Timed out waiting for {url}; last={last}")


def _provider_command(database, port, station_id, station_code, token):
    return [
        CENTRAL_PYTHON,
        PROVIDER,
        "--database",
        database,
        "--port",
        port,
        "--station-id",
        station_id,
        "--station-code",
        station_code,
        "--token",
        token,
        "--demo-op",
        "OP-E2E-MONITOR",
        "--demo-target-kg",
        "100",
    ]


def _auth_headers(token):
    return {
        "Authorization": f"Bearer {token}",
        "X-Station-Version": "1.1.0-pilot",
        "X-Correlation-Id": str(uuid.uuid4()),
    }


def _capture(origin, number, weight):
    response = requests.post(
        f"{origin}/api/local/v1/pesajes",
        headers={"Idempotency-Key": str(uuid.uuid4())},
        json={
            "peso_kg": weight,
            "nro_op": "OP-E2E-MONITOR",
            "nro_orden_trabajo": f"OT-E2E-{number:03d}",
            "fecha_orden_trabajo": "2026-07-17",
            "maquina": "INY-E2E",
            "turno": "DIURNO",
        },
        timeout=3,
    )
    assert response.status_code == 201, response.text


def main():
    if os.name != "nt":
        raise SystemExit("This E2E exercises Windows DPAPI and requires Windows")
    if not STATIC_DIR.joinpath("index.html").is_file():
        raise SystemExit("Build modulo-pesaje/frontend before running this E2E")

    run_root = Path("C:/tmp") / f"envaperu-monitoring-e2e-{uuid.uuid4().hex}"
    run_root.mkdir(parents=True)
    central_database = run_root / "central.db"
    station_data = run_root / "station"
    station_code = f"PESAJE-E2E-{uuid.uuid4().hex[:8].upper()}"
    station_id = str(uuid.uuid4())
    token = f"e2e-{uuid.uuid4().hex}-{uuid.uuid4().hex}"
    central_port = _free_port()
    station_port = _free_port()
    central_origin = f"http://127.0.0.1:{central_port}"
    station_origin = f"http://127.0.0.1:{station_port}"
    provider = None
    station = None

    try:
        provider_command = _provider_command(
            central_database,
            central_port,
            station_id,
            station_code,
            token,
        )
        provider = _start(provider_command, CENTRAL)
        _wait_json(
            f"{central_origin}/api/integration/v1/capabilities",
            lambda body: body.get("api_version") == "integration-v1",
            headers=_auth_headers(token),
            process=provider,
        )

        provision = subprocess.run(
            [
                str(STATION_PYTHON),
                str(STATION_CONTROL),
                "provision-token",
                "--data-root",
                str(station_data),
                "--token-stdin",
            ],
            cwd=STATION / "backend",
            input=token + "\n",
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=10,
            check=False,
        )
        assert provision.returncode == 0, provision.stdout + provision.stderr
        assert "STATION_TOKEN_PROVISIONED" in provision.stdout

        station = _start(
            [
                STATION_PYTHON,
                STATION_MAIN,
                "--port",
                station_port,
                "--static-dir",
                STATIC_DIR,
                "--data-root",
                station_data,
                "--station-id",
                station_code,
            ],
            STATION / "backend",
            env={
                "CENTRAL_ORIGIN": central_origin,
                "STATION_UUID": station_id,
                "HEARTBEAT_SECONDS": "5",
            },
        )
        _wait_json(
            f"{station_origin}/api/local/v1/health/ready",
            lambda body: body.get("status") == "READY",
            process=station,
        )
        _wait_json(
            f"{central_origin}/api/monitoring/v1/weighing-stations/{station_id}",
            lambda body: body.get("communication_status") == "RECIENTE",
        )

        _capture(station_origin, 1, "25.000")
        _wait_json(
            f"{central_origin}/api/monitoring/v1/weighing-stations/{station_id}",
            lambda body: body.get("communication", {}).get(
                "legacy_unsynced_count"
            ) == 1,
            timeout=15,
        )
        first_progress = _wait_json(
            f"{central_origin}/api/monitoring/v1/production-progress"
            "?date=2026-07-17",
            lambda body: body.get("summary", {}).get("weight_kg") == "25.000",
            timeout=15,
        )
        assert first_progress["summary"]["bags"] == 1
        assert first_progress["items"][0]["op"] == "OP-E2E-MONITOR"
        assert first_progress["items"][0]["progress_percent"] == 25.0

        _stop(provider)
        provider = None
        _wait_json(
            f"{station_origin}/api/local/v1/health/ready",
            lambda body: body.get("central", {}).get("state")
            == "CENTRAL_UNREACHABLE",
            timeout=15,
        )
        _capture(station_origin, 2, "30.000")
        _capture(station_origin, 3, "30.125")
        _capture(station_origin, 4, "29.875")

        provider = _start(provider_command, CENTRAL)
        _wait_json(
            f"{central_origin}/api/integration/v1/capabilities",
            lambda body: body.get("api_version") == "integration-v1",
            headers=_auth_headers(token),
            process=provider,
        )
        recovered = _wait_json(
            f"{central_origin}/api/monitoring/v1/weighing-stations/{station_id}",
            lambda body: body.get("communication", {}).get(
                "legacy_unsynced_count"
            ) == 4,
            timeout=35,
        )
        assert recovered["local_summary"]["source"] == "LOCAL_REPORTED_LEGACY"
        assert recovered["local_summary"]["weight_kg"] == "115.000"
        recovered_progress = _wait_json(
            f"{central_origin}/api/monitoring/v1/production-progress"
            "?date=2026-07-17",
            lambda body: body.get("summary", {}).get("weight_kg") == "115.000",
            timeout=15,
        )
        assert recovered_progress["summary"]["bags"] == 4
        assert recovered_progress["summary"]["production_orders"] == 1
        assert recovered_progress["items"][0]["progress_percent"] == 115.0

        stop_result = subprocess.run(
            [
                str(STATION_PYTHON),
                str(STATION_CONTROL),
                "stop",
                "--station-id",
                station_code,
            ],
            cwd=STATION / "backend",
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        assert stop_result.returncode == 0, stop_result.stdout + stop_result.stderr
        assert station.wait(timeout=15) == 0
        station = None

        _stop(provider)
        provider = None
        with sqlite3.connect(central_database) as connection:
            control_peso_count = connection.execute(
                "SELECT COUNT(*) FROM control_peso"
            ).fetchone()[0]
            heartbeat_count = connection.execute(
                "SELECT COUNT(*) FROM estacion_heartbeat_recepcion"
            ).fetchone()[0]
            progress_report_count = connection.execute(
                "SELECT COUNT(*) FROM estacion_reporte_avance_recepcion"
            ).fetchone()[0]
            progress_row_count = connection.execute(
                "SELECT COUNT(*) FROM estacion_avance_produccion"
            ).fetchone()[0]
        with sqlite3.connect(station_data / "data" / "pesajes.db") as connection:
            pesaje_count = connection.execute(
                "SELECT COUNT(*) FROM pesajes"
            ).fetchone()[0]

        assert control_peso_count == 0
        assert heartbeat_count >= 2
        assert progress_report_count >= 3
        assert progress_row_count == 4
        assert pesaje_count == 4
        print(
            "MONITORING_E2E_OK "
            f"station_id={station_id} pesajes={pesaje_count} "
            f"heartbeats={heartbeat_count} progress_reports={progress_report_count} "
            f"progress_rows={progress_row_count} control_peso={control_peso_count}",
            flush=True,
        )
        return 0
    finally:
        _stop(station)
        _stop(provider)


if __name__ == "__main__":
    raise SystemExit(main())
