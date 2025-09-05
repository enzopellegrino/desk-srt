@echo off
REM Desk SRT - Script di installazione per Windows Server 2022
REM Questo script installa le dipendenze necessarie per l'applicazione

echo ================================
echo  Desk SRT - Setup Installer
echo  Windows Server 2022 Edition
echo ================================
echo.

REM Verifica Python
echo Verificando Python...
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: Python non trovato!
    echo Installa Python 3.8+ da https://www.python.org/downloads/
    pause
    exit /b 1
)
echo Python trovato: 
python --version

echo.
REM Verifica pip
echo Verificando pip...
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: pip non trovato!
    echo Installa pip o reinstalla Python
    pause
    exit /b 1
)

echo.
REM Installa dipendenze Python
echo Installando dipendenze Python...
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo ERRORE: Installazione dipendenze fallita!
    pause
    exit /b 1
)

echo.
REM Verifica FFmpeg
echo Verificando FFmpeg...
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ATTENZIONE: FFmpeg non trovato nel PATH!
    echo.
    echo Per installare FFmpeg:
    echo 1. Scarica FFmpeg con supporto NVENC da:
    echo    https://ffmpeg.org/download.html#build-windows
    echo 2. Estrai l'archivio
    echo 3. Aggiungi la cartella bin al PATH di sistema
    echo    OPPURE
    echo 4. Copia ffmpeg.exe nella cartella di questo progetto
    echo.
    echo Vuoi scaricare FFmpeg automaticamente? (s/n)
    set /p download_ffmpeg="Risposta: "
    
    if /i "%download_ffmpeg%"=="s" (
        echo.
        echo Scaricando FFmpeg...
        REM Questo richiede PowerShell per il download
        powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile 'ffmpeg.zip'}"
        
        if exist ffmpeg.zip (
            echo Estraendo FFmpeg...
            powershell -Command "& {Expand-Archive -Path 'ffmpeg.zip' -DestinationPath '.' -Force}"
            
            REM Trova la cartella estratta e copia ffmpeg.exe
            for /d %%i in (ffmpeg-master-latest-win64-gpl*) do (
                if exist "%%i\bin\ffmpeg.exe" (
                    copy "%%i\bin\ffmpeg.exe" .
                    echo FFmpeg copiato con successo!
                )
            )
            
            REM Pulizia
            del ffmpeg.zip
            for /d %%i in (ffmpeg-master-latest-win64-gpl*) do (
                rd /s /q "%%i"
            )
        ) else (
            echo Download fallito. Installa FFmpeg manualmente.
        )
    )
) else (
    echo FFmpeg trovato:
    ffmpeg -version | findstr "ffmpeg version"
)

echo.
REM Verifica supporto NVENC
echo Verificando supporto NVENC...
ffmpeg -encoders 2>nul | findstr "h264_nvenc" >nul
if %errorlevel% neq 0 (
    echo ATTENZIONE: NVENC non disponibile in questo build di FFmpeg!
    echo Assicurati di avere:
    echo 1. Una GPU NVIDIA con supporto NVENC
    echo 2. Driver NVIDIA aggiornati
    echo 3. FFmpeg compilato con supporto NVENC
) else (
    echo Supporto NVENC trovato!
)

echo.
REM Verifica GPU NVIDIA
echo Verificando GPU NVIDIA...
nvidia-smi >nul 2>&1
if %errorlevel% neq 0 (
    echo ATTENZIONE: nvidia-smi non trovato!
    echo Verifica che i driver NVIDIA siano installati
) else (
    echo GPU NVIDIA rilevata:
    nvidia-smi --query-gpu=name --format=csv,noheader,nounits
)

echo.
echo ================================
echo  Setup completato!
echo ================================
echo.
echo Per avviare l'applicazione:
echo   python desk_srt.py
echo.
echo Note importanti:
echo - L'app rimarrà sempre in primo piano
echo - Posizionata nell'angolo in alto a destra
echo - Configura gli endpoint SRT in config/settings.ini
echo - Usa Ctrl+C nel terminale per fermare
echo.

pause
