@echo off
REM Desk SRT - Script di Debug
REM Aiuta a diagnosticare problemi di installazione

title Desk SRT - Diagnostica

echo ================================
echo   Desk SRT - Diagnostica Sistema
echo ================================
echo.

REM Cambia alla directory dello script
cd /d "%~dp0"

echo 1. INFORMAZIONI DIRECTORY
echo ==========================
echo Directory corrente: %CD%
echo Directory script: %~dp0
echo.

echo 2. CONTENUTO DIRECTORY
echo ======================
echo File Python:
dir /b *.py 2>nul
if errorlevel 1 echo   Nessun file Python trovato
echo.

echo File Batch:
dir /b *.bat 2>nul
if errorlevel 1 echo   Nessun file batch trovato
echo.

echo Directory:
dir /b /ad 2>nul
if errorlevel 1 echo   Nessuna sottodirectory trovata
echo.

echo 3. VERIFICA COMPONENTI
echo ======================

REM Verifica desk_srt.py
if exist "desk_srt.py" (
    echo [OK] desk_srt.py trovato
) else (
    echo [ERRORE] desk_srt.py NON trovato
)

REM Verifica utils.py
if exist "utils.py" (
    echo [OK] utils.py trovato
) else (
    echo [ATTENZIONE] utils.py NON trovato
)

REM Verifica config
if exist "config\settings.ini" (
    echo [OK] config\settings.ini trovato
) else (
    echo [ATTENZIONE] config\settings.ini NON trovato
)

REM Verifica logs
if exist "logs" (
    echo [OK] Directory logs presente
) else (
    echo [INFO] Directory logs non presente (verrà creata)
)

echo.

echo 4. VERIFICA PYTHON
echo ==================
python --version >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] Python installato:
    python --version
    echo Percorso Python:
    where python 2>nul
    echo.
    
    echo Verifica moduli richiesti:
    python -c "import tkinter; print('[OK] tkinter disponibile')" 2>nul || echo "[ERRORE] tkinter non disponibile"
    python -c "import subprocess; print('[OK] subprocess disponibile')" 2>nul || echo "[ERRORE] subprocess non disponibile"
    python -c "import configparser; print('[OK] configparser disponibile')" 2>nul || echo "[ERRORE] configparser non disponibile"
    python -c "import pathlib; print('[OK] pathlib disponibile')" 2>nul || echo "[ERRORE] pathlib non disponibile"
    
    echo Tentativo import psutil:
    python -c "import psutil; print('[OK] psutil disponibile')" 2>nul || echo "[ATTENZIONE] psutil non disponibile - esegui: pip install psutil"
    
) else (
    echo [ERRORE] Python NON installato o non nel PATH
    echo.
    echo Possibili soluzioni:
    echo 1. Installa Python da https://www.python.org/downloads/
    echo 2. Aggiungi Python al PATH di sistema
    echo 3. Esegui install_python.bat se presente
)

echo.

echo 5. VERIFICA FFMPEG
echo ==================
ffmpeg -version >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] FFmpeg installato:
    ffmpeg -version 2>nul | findstr "ffmpeg version"
    echo.
    echo Verifica supporto NVENC:
    ffmpeg -encoders 2>nul | findstr "h264_nvenc" >nul
    if %errorlevel% == 0 (
        echo [OK] Supporto NVENC presente
    ) else (
        echo [ATTENZIONE] Supporto NVENC non rilevato
    )
) else (
    echo [ATTENZIONE] FFmpeg non installato o non nel PATH
    echo.
    if exist "ffmpeg.exe" (
        echo [INFO] ffmpeg.exe presente nella directory corrente
    ) else (
        echo [INFO] Esegui install_ffmpeg.bat se presente per scaricare FFmpeg
    )
)

echo.

echo 6. VERIFICA GPU NVIDIA
echo ======================
nvidia-smi --query-gpu=name --format=csv,noheader >nul 2>&1
if %errorlevel% == 0 (
    echo [OK] GPU NVIDIA rilevata:
    nvidia-smi --query-gpu=name --format=csv,noheader 2>nul
) else (
    echo [INFO] GPU NVIDIA non rilevata o driver non installati
    echo Questo non impedisce il funzionamento base dell'applicazione
)

echo.

echo 7. SCRIPT DISPONIBILI
echo =====================
if exist "install_python.bat" echo [DISPONIBILE] install_python.bat
if exist "install_ffmpeg.bat" echo [DISPONIBILE] install_ffmpeg.bat
if exist "start.bat" echo [DISPONIBILE] start.bat
if exist "setup.bat" echo [DISPONIBILE] setup.bat

echo.
echo ================================
echo   Diagnostica Completata
echo ================================
echo.

if exist "desk_srt.py" (
    echo STATO: Pronto per l'avvio
    echo Esegui start.bat per avviare l'applicazione
) else (
    echo STATO: Problemi rilevati
    echo Reinstalla l'applicazione o verifica l'installazione
)

echo.
pause
