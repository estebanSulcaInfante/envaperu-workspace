import json
import os
import socket
import subprocess
import tempfile
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


WORKSPACE = Path(__file__).resolve().parents[1]


def venv_python(project_dir):
    scripts_dir = "Scripts" if os.name == "nt" else "bin"
    executable = "python.exe" if os.name == "nt" else "python"
    path = project_dir / ".venv" / scripts_dir / executable
    if not path.exists():
        raise RuntimeError(f"Missing virtual environment interpreter: {path}")
    return path


def reserve_port():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def sqlite_url(path):
    return f"sqlite:///{path.resolve().as_posix()}"


def request_json(method, url, payload=None, timeout=5):
    body = None
    headers = {}
    if payload is not None:
        body = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"

    request = Request(url, data=body, headers=headers, method=method)
    try:
        with urlopen(request, timeout=timeout) as response:
            raw = response.read().decode("utf-8")
            return response.status, json.loads(raw) if raw else None
    except HTTPError as error:
        raw = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} returned {error.code}: {raw}") from error


def wait_until_ready(name, process, url, timeout=20):
    deadline = time.monotonic() + timeout
    last_error = None

    while time.monotonic() < deadline:
        if process.poll() is not None:
            raise RuntimeError(f"{name} exited before becoming ready")

        try:
            status, _ = request_json("GET", url, timeout=1)
            if status == 200:
                return
        except (RuntimeError, URLError, TimeoutError) as error:
            last_error = error

        time.sleep(0.2)

    raise RuntimeError(f"{name} was not ready after {timeout}s: {last_error}")


def start_server(command, cwd, extra_env):
    environment = os.environ.copy()
    environment.update(extra_env)
    environment["PYTHONUNBUFFERED"] = "1"
    existing_python_path = environment.get("PYTHONPATH")
    environment["PYTHONPATH"] = str(cwd)
    if existing_python_path:
        environment["PYTHONPATH"] += os.pathsep + existing_python_path
    creation_flags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0

    return subprocess.Popen(
        [str(part) for part in command],
        cwd=str(cwd),
        env=environment,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding="utf-8",
        errors="replace",
        creationflags=creation_flags,
    )


def stop_server(process):
    if process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)

    output, _ = process.communicate(timeout=5)
    return output


def main():
    backend_dir = WORKSPACE / "backend"
    weighing_dir = WORKSPACE / "modulo-pesaje" / "backend"
    backend_python = venv_python(backend_dir)
    weighing_python = venv_python(weighing_dir)
    central_port = reserve_port()
    weighing_port = reserve_port()
    processes = []
    failed = False

    with tempfile.TemporaryDirectory(prefix="envaperu-sync-e2e-") as temp_dir:
        temp_path = Path(temp_dir)

        try:
            central = start_server(
                [backend_python, backend_dir / "tests" / "support" / "run_sync_provider.py"],
                backend_dir,
                {
                    "DATABASE_URL": sqlite_url(temp_path / "central.db"),
                    "TEST_PORT": str(central_port),
                    "DEBUG": "false",
                },
            )
            processes.append(("central", central))
            wait_until_ready(
                "central",
                central,
                f"http://127.0.0.1:{central_port}/api/ordenes",
            )

            weighing = start_server(
                [weighing_python, weighing_dir / "tests" / "support" / "run_sync_consumer.py"],
                weighing_dir,
                {
                    "DATABASE_URL": sqlite_url(temp_path / "weighing.db"),
                    "CENTRAL_API_URL": f"http://127.0.0.1:{central_port}/api",
                    "TEST_PORT": str(weighing_port),
                    "API_PORT": str(weighing_port),
                    "SYNC_ENABLED": "false",
                    "DEBUG": "false",
                    "TESTING": "true",
                },
            )
            processes.append(("weighing", weighing))
            wait_until_ready(
                "weighing",
                weighing,
                f"http://127.0.0.1:{weighing_port}/api/pesajes",
            )

            _, created = request_json(
                "POST",
                f"http://127.0.0.1:{weighing_port}/api/pesajes",
                {
                    "peso_kg": 12.5,
                    "molde": "MOLDE E2E",
                    "maquina": "MAQUINA E2E",
                    "nro_op": "OP-E2E-SYNC-001",
                    "turno": "DIURNO",
                    "fecha_orden_trabajo": "2026-07-13",
                    "nro_orden_trabajo": "30001",
                    "operador": "OPERADOR E2E",
                    "color": "ROJO",
                    "pieza_sku": "PZ-E2E-ROJO",
                    "pieza_nombre": "PIEZA E2E ROJO",
                    "qr_data_original": "QR-E2E-001",
                },
            )
            local_id = created["id"]

            _, sync_result = request_json(
                "POST",
                f"http://127.0.0.1:{weighing_port}/api/sync/trigger",
                {},
                timeout=10,
            )
            if sync_result["synced"] != [{"local_id": local_id}]:
                raise AssertionError(f"Unexpected sync response: {sync_result}")

            _, local_pesaje = request_json(
                "GET",
                f"http://127.0.0.1:{weighing_port}/api/pesajes/{local_id}",
            )
            if local_pesaje["sincronizado"] is not True:
                raise AssertionError("The weighing record was not marked as synchronized")

            _, central_order = request_json(
                "GET",
                f"http://127.0.0.1:{central_port}/api/ordenes/OP-E2E-SYNC-001",
            )
            if central_order["avance_real_kg"] != 12.5:
                raise AssertionError(f"Unexpected central total: {central_order['avance_real_kg']}")

            print("Isolated sync E2E passed: 12.5 kg reached central and local state was acknowledged.")
        except Exception:
            failed = True
            raise
        finally:
            for name, process in reversed(processes):
                output = stop_server(process)
                if failed and output:
                    print(f"\n===== {name} server output =====\n{output}")


if __name__ == "__main__":
    main()
