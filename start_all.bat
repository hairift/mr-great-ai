@echo off
echo ============================================
echo   Mr. Great AI - One Click Launcher
echo ============================================
echo.

:: Start Python server in background
echo [1/2] Memulai AI Server...
cd /d "%~dp0server"

:: Check if .venv exists
if exist "..\\.venv\\Scripts\\python.exe" (
    start "MrGreat-AI-Server" /min "..\.venv\Scripts\python.exe" main.py
) else (
    start "MrGreat-AI-Server" /min python main.py
)

:: Wait for server to start
timeout /t 3 /nobreak > nul

:: Go back to root and run Flutter
echo [2/2] Menjalankan Aplikasi Flutter...
cd /d "%~dp0"
flutter run

:: When Flutter exits, stop the server
echo.
echo Mematikan AI Server...
taskkill /fi "WINDOWTITLE eq MrGreat-AI-Server" /f > nul 2>&1
echo Selesai!
pause
