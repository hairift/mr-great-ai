"""Persistent server runner — keeps the AI server alive forever.

This script:
- Starts the FastAPI server
- If it crashes, automatically restarts it after 5 seconds
- Logs everything to server.log
- Runs silently in the background

Used by Windows Task Scheduler to auto-start on boot.
"""

import subprocess
import sys
import os
import time
import logging

# Setup logging
LOG_FILE = os.path.join(os.path.dirname(__file__), "server_runner.log")
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)

SERVER_DIR = os.path.dirname(os.path.abspath(__file__))
RESTART_DELAY = 5  # seconds between restart attempts
MAX_RESTARTS = 100  # max consecutive restarts before giving up


def find_python():
    """Find the Python executable — checks venv first."""
    venv_python = os.path.join(SERVER_DIR, "..", ".venv", "Scripts", "python.exe")
    if os.path.exists(venv_python):
        return os.path.abspath(venv_python)

    venv_python2 = os.path.join(SERVER_DIR, "venv", "Scripts", "python.exe")
    if os.path.exists(venv_python2):
        return os.path.abspath(venv_python2)

    return sys.executable


def run_server():
    """Run the FastAPI server and restart on crash."""
    python_exe = find_python()
    main_py = os.path.join(SERVER_DIR, "main.py")

    logging.info(f"=== Mr. Great AI Server Runner ===")
    logging.info(f"Python: {python_exe}")
    logging.info(f"Server: {main_py}")
    logging.info(f"Working dir: {SERVER_DIR}")

    restart_count = 0

    while restart_count < MAX_RESTARTS:
        try:
            logging.info(f"Starting server (attempt {restart_count + 1})...")

            process = subprocess.Popen(
                [python_exe, main_py],
                cwd=SERVER_DIR,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
            )

            # Stream output to log
            for line in iter(process.stdout.readline, ""):
                if line:
                    logging.info(f"[SERVER] {line.strip()}")

            exit_code = process.wait()
            logging.warning(f"Server exited with code {exit_code}")

        except Exception as e:
            logging.error(f"Server crashed: {e}")

        restart_count += 1
        if restart_count < MAX_RESTARTS:
            logging.info(f"Restarting in {RESTART_DELAY} seconds...")
            time.sleep(RESTART_DELAY)

    logging.error(f"Max restarts ({MAX_RESTARTS}) reached. Giving up.")


if __name__ == "__main__":
    run_server()
