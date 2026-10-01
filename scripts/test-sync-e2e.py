import json
import os
import socket
import subprocess
import tempfile
import time
from collections import deque
from threading import Thread
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import ProxyHandler, Request, build_opener, urlopen


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
        # Only local test traffic bypasses machine/runner proxy configuration.
        opener = (
            build_opener(ProxyHandler({})).open
            if urlsplit(url).hostname in {"127.0.0.1", "localhost", "::1"}
            else urlopen
        )
        with opener(request, timeout=timeout) as response:
            raw = response.read().decode("utf-8")
            return response.status, json.loads(raw) if raw else None
    except HTTPError as error:
        raw = error.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"{method} {url} returned {error.code}: {raw}") from error


def wait_until_ready(name, process, url, timeout=60):
    started = time.monotonic()
    deadline = started + timeout
    next_progress = started + 5
    last_error = None
    print(f"Waiting for {name} pid={process.pid}: {url} (deadline {timeout}s)", flush=True)

    while time.monotonic() < deadline:
        exit_code = process.poll()
        if exit_code is not None:
            raise RuntimeError(f"{name} exited before becoming ready: exit code {exit_code}")
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            break
        try:
            status, _ = request_json("GET", url, timeout=min(1, remaining))
            if status == 200:
                print(f"{name} ready after {time.monotonic() - started:.1f}s", flush=True)
                return
        except (RuntimeError, URLError, TimeoutError) as error:
            last_error = error
        now = time.monotonic()
        if now >= next_progress:
            print(f"{name} still starting after {now - started:.1f}s: {last_error}", flush=True)
            next_progress = now + 5
        time.sleep(max(0, min(0.2, deadline - now)))

    raise RuntimeError(f"{name} pid={process.pid} was not ready after {timeout}s: {last_error}")


def start_server(command, cwd, extra_env):
    environment = os.environ.copy()
    environment.update(extra_env)
    environment["PYTHONUNBUFFERED"] = "1"
    # Affect only these child processes; preserve existing non-loopback entries.
    for key in ("NO_PROXY", "no_proxy"):
        entries = [environment.get(key, ""), "127.0.0.1", "localhost", "::1"]
        environment[key] = ",".join(entry for entry in entries if entry)
    existing_python_path = environment.get("PYTHONPATH")
    environment["PYTHONPATH"] = str(cwd)
    if existing_python_path:
        environment["PYTHONPATH"] += os.pathsep + existing_python_path
    creation_flags = subprocess.CREATE_NO_WINDOW if os.name == "nt" else 0

    process = subprocess.Popen(
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

    # Drain continuously: a full PIPE must not block server initialization.
    # At most 16 * 4096 characters are retained, regardless of server verbosity.
    process.e2e_output = deque(maxlen=16)

    def drain_output():
        for chunk in iter(lambda: process.stdout.read(4096), ""):
            process.e2e_output.append(chunk)

    process.e2e_reader = Thread(target=drain_output, daemon=True)
    process.e2e_reader.start()
    print(f"Started pid={process.pid}: {command[0]} {command[1]} (cwd={cwd})", flush=True)
    return process


def stop_server(process):
    if process.poll() is None:
        process.terminate()
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            process.kill()
            process.wait(timeout=5)

    process.e2e_reader.join(timeout=5)
    output = "".join(list(process.e2e_output))
    if process.e2e_reader.is_alive():
        # A late diagnostic reader must not abort cleanup of the other server
        # or replace the original E2E failure. Do not close its active stream.
        output += f"\n[pid={process.pid}: output reader still running after 5s]"
    else:
        process.stdout.close()
    return output[-65536:]



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
                if failed:
                    print(
                        f"\n===== {name} pid={process.pid} exit={process.returncode} "
                        f"server output tail (max 65536 chars) =====\n{output or '(no output captured)'}",
                        flush=True,
                    )


if __name__ == "__main__":
    main()
