@echo off
REM Desk SRT - Avvio rapido
REM Questo script avvia l'applicazione Desk SRT

title Desk SRT - Screen Capture to SRT

echo ================================
echo  Desk SRT - Avvio Applicazione
echo ================================
echo.

REM Cambia alla directory dello script
cd /d "%~dp0"

REM Mostra directory corrente per debug
echo Directory corrente: %CD%
echo.

REM Controlla se siamo nella directory corretta
if not exist "desk_srt.py" (
    echo ERRORE: desk_srt.py non trovato!
    echo Directory corrente: %CD%
    echo.
    echo Contenuto directory:
    dir /b *.py 2>nul
    if errorlevel 1 (
        echo Nessun file Python trovato in questa directory
    )
    echo.
    echo Verifica che l'installazione sia completata correttamente
    pause
    exit /b 1
)

REM Controlla configurazione
if not exist "config\settings.ini" (
    echo ATTENZIONE: File di configurazione non trovato!
    echo Verrà usata la configurazione predefinita
    echo.
    REM Crea directory config se non esiste
    if not exist "config" mkdir config
    echo Creando configurazione predefinita...
    echo [SRT_ENDPOINTS] > config\settings.ini
    echo endpoints = srt://direct-obs4.wyscout.com:10080,srt://direct-obs4.wyscout.com:10081 >> config\settings.ini
    echo. >> config\settings.ini
    echo [VIDEO_SETTINGS] >> config\settings.ini
    echo fps = 30 >> config\settings.ini
    echo bitrate = 2000000 >> config\settings.ini
    echo resolution = 1920x1080 >> config\settings.ini
    echo preset = fast >> config\settings.ini
    echo. >> config\settings.ini
    echo [ENCODER_SETTINGS] >> config\settings.ini
    echo codec = h264_nvenc >> config\settings.ini
    echo gpu_device = 0 >> config\settings.ini
    echo rc_mode = cbr >> config\settings.ini
    echo profile = high >> config\settings.ini
    echo. >> config\settings.ini
    echo [GUI_SETTINGS] >> config\settings.ini
    echo window_width = 300 >> config\settings.ini
    echo window_height = 150 >> config\settings.ini
    echo always_on_top = true >> config\settings.ini
    echo minimize_to_tray = true >> config\settings.ini
    echo. >> config\settings.ini
    echo [CAPTURE_SETTINGS] >> config\settings.ini
    echo input_format = gdigrab >> config\settings.ini
    echo input_device = desktop >> config\settings.ini
    echo framerate = 30 >> config\settings.ini
    echo show_cursor = true >> config\settings.ini
    echo Configurazione creata!
    echo.
)

REM Verifica Python
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: Python non trovato!
    echo.
    echo Soluzioni:
    echo 1. Installa Python da https://www.python.org/downloads/
    echo 2. Oppure esegui install_python.bat se presente
    echo 3. Aggiungi Python al PATH di sistema
    echo.
    if exist "install_python.bat" (
        echo Trovato script installazione Python. Vuoi eseguirlo? (s/n)
        set /p install_py="Risposta: "
        if /i "!install_py!"=="s" (
            echo Esecuzione install_python.bat...
            call install_python.bat
            echo.
            echo Riprova ad avviare Desk SRT
        )
    )
    pause
    exit /b 1
)

echo Python trovato: 
python --version
echo.

echo Avviando Desk SRT...
echo.
echo Per fermare l'applicazione:
echo - Chiudi la finestra GUI
echo - Oppure premi Ctrl+C in questo terminale
echo.
echo ================================
echo.

REM Avvia l'applicazione
python desk_srt.py

echo.
echo Applicazione terminata.
pause
