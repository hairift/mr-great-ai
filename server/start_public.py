"""Start Mr. Great AI server with ngrok tunnel for public access.

This script:
1. Starts the FastAPI server on localhost:8000
2. Creates an ngrok tunnel to make it publicly accessible
3. Prints the public URL to use in api_config.dart

Usage:
    python start_public.py

The public URL will be printed — copy it to lib/api_config.dart:
    static String get baseUrl => "https://xxxx-xxx.ngrok-free.app";
"""

import subprocess
import sys
import time
import threading
import signal

def start_server():
    """Start the FastAPI server."""
    return subprocess.Popen(
        [sys.executable, "main.py"],
        cwd=".",
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1,
    )

def stream_output(process, prefix=""):
    """Stream process output to console."""
    try:
        for line in iter(process.stdout.readline, ""):
            if line:
                print(f"{prefix}{line}", end="")
    except Exception:
        pass

def main():
    print("=" * 60)
    print("🚀 Mr. Great AI — Public Server Launcher")
    print("=" * 60)

    # Step 1: Start FastAPI server
    print("\n📡 Starting FastAPI server on localhost:8000...")
    server_proc = start_server()

    # Stream server output in background
    server_thread = threading.Thread(
        target=stream_output, args=(server_proc, "[SERVER] "), daemon=True
    )
    server_thread.start()

    time.sleep(3)  # Wait for server to start

    # Step 2: Start ngrok tunnel
    print("\n🌐 Starting ngrok tunnel...")
    try:
        from pyngrok import ngrok, conf

        # Set ngrok config
        conf.get_default().log_level = "warn"

        # Create tunnel
        tunnel = ngrok.connect(8000, "http")
        public_url = tunnel.public_url

        print("\n" + "=" * 60)
        print("✅ SERVER IS LIVE AND PUBLIC!")
        print("=" * 60)
        print(f"\n🌐 Public URL: {public_url}")
        print(f"📱 Local URL:  http://localhost:8000")
        print(f"\n📋 Copy this to lib/api_config.dart:")
        print(f'   return "{public_url}";')
        print(f"\n🔑 API Key: mrgreat-ucic-2024-secret-key")
        print(f"\n💡 Test: {public_url}/api/health")
        print(f"\n⛔ Press Ctrl+C to stop\n")

        # Keep running
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n\n🛑 Shutting down...")
            ngrok.disconnect(tunnel.public_url)
            ngrok.kill()

    except ImportError:
        print("❌ pyngrok not installed. Run: pip install pyngrok")
        print("   Falling back to local-only mode...")
        print(f"\n📱 Server running at: http://localhost:8000")
        print(f"⛔ Press Ctrl+C to stop\n")

        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n🛑 Shutting down...")
    except Exception as e:
        print(f"⚠️ ngrok error: {e}")
        print("   Server still running at http://localhost:8000")
        print(f"   You can manually run: ngrok http 8000")
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            print("\n🛑 Shutting down...")

    finally:
        server_proc.terminate()
        server_proc.wait(timeout=5)
        print("✅ Server stopped.")

if __name__ == "__main__":
    main()
