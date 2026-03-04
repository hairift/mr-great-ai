@echo off
echo ============================================
echo   Mr. Great AI - Setup Auto-Start (SEKALI)
echo ============================================
echo.
echo Script ini akan:
echo  - Buka port 8000 di Windows Firewall
echo  - Daftarkan server AI agar OTOMATIS JALAN
echo    setiap kali Windows dinyalakan
echo.
echo PENTING: Jalankan sebagai Administrator!
echo (Klik kanan - Run as administrator)
echo.
pause

:: Get the full paths
set "PROJECT_DIR=%~dp0"
set "SERVER_DIR=%PROJECT_DIR%server"
set "VENV_PYTHONW=%PROJECT_DIR%.venv\Scripts\pythonw.exe"
set "VENV_PYTHON=%PROJECT_DIR%.venv\Scripts\python.exe"

:: Check which Python to use (pythonw = no console window)
if exist "%VENV_PYTHONW%" (
    set "PYTHON_EXE=%VENV_PYTHONW%"
    echo [OK] Virtual environment ditemukan
) else if exist "%VENV_PYTHON%" (
    set "PYTHON_EXE=%VENV_PYTHON%"
    echo [OK] Virtual environment ditemukan
) else (
    set "PYTHON_EXE=pythonw.exe"
    echo [OK] Menggunakan system Python
)

echo.
echo [1/3] Membuka port 8000 di Windows Firewall...
netsh advfirewall firewall delete rule name="MrGreatAI-Server" >nul 2>&1
netsh advfirewall firewall add rule name="MrGreatAI-Server" dir=in action=allow protocol=tcp localport=8000

if %errorlevel% equ 0 (
    echo       [OK] Port 8000 sudah dibuka!
) else (
    echo       [GAGAL] Jalankan sebagai Administrator!
    pause
    exit /b 1
)

echo.
echo [2/3] Mendaftarkan server AI ke Windows Startup...

:: Delete old task if exists
schtasks /delete /tn "MrGreatAIServer" /f >nul 2>&1

:: Create new task that runs at logon
schtasks /create /tn "MrGreatAIServer" /tr "\"%PYTHON_EXE%\" \"%SERVER_DIR%\server_forever.py\"" /sc onlogon /rl highest /f

if %errorlevel% equ 0 (
    echo       [OK] Server terdaftar di Windows Startup!
) else (
    echo       [GAGAL] Tidak bisa mendaftar. Pastikan Run as Administrator.
    pause
    exit /b 1
)

echo.
echo [3/3] Memulai server AI sekarang...

:: Kill existing server if running
taskkill /f /fi "WINDOWTITLE eq MrGreat*" >nul 2>&1

:: Start the persistent server
start "" /min "%PYTHON_EXE%" "%SERVER_DIR%\server_forever.py"

:: Wait a moment
timeout /t 4 /nobreak >nul

echo.
echo ============================================
echo   SETUP SELESAI!
echo ============================================
echo.
echo   Server AI sekarang:
echo   - Berjalan di background
echo   - OTOMATIS jalan saat Windows nyala
echo   - Auto-restart kalau crash
echo.
echo   IP Komputer kamu:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4"') do echo      %%a
echo.
echo   URL untuk HP (WiFi sama):
echo   http://192.168.1.7:8000
echo.
echo   Cek status:
echo   http://192.168.1.7:8000/api/health
echo.
echo   ---- CARA HAPUS AUTO-START ----
echo   schtasks /delete /tn "MrGreatAIServer" /f
echo   netsh advfirewall firewall delete rule name="MrGreatAI-Server"
echo.
pause
