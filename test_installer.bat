@echo off
REM Desk SRT - Test Installer Script
REM Per testare l'installer in ambiente di sviluppo

echo ================================
echo  Desk SRT - Test Installer
echo ================================
echo.

REM Verifica se l'installer esiste
if not exist "DeskSRT_Installer.exe" (
    echo ERRORE: Installer non trovato!
    echo.
    echo Esegui prima build_installer.bat per creare l'installer.
    pause
    exit /b 1
)

echo Installer trovato: DeskSRT_Installer.exe

REM Mostra informazioni installer
echo.
echo Informazioni installer:
for %%I in (DeskSRT_Installer.exe) do (
    echo - Dimensione: %%~zI bytes
    echo - Data: %%~tI
)

echo.
echo Opzioni di test:
echo.
echo 1. Test installazione normale (richiede privilegi admin)
echo 2. Test installazione silenziosa
echo 3. Test solo verifica dipendenze (dry-run)
echo 4. Apri cartella con installer
echo 5. Esci
echo.

set /p choice="Seleziona opzione (1-5): "

if "%choice%"=="1" goto test_normal
if "%choice%"=="2" goto test_silent
if "%choice%"=="3" goto test_dryrun
if "%choice%"=="4" goto open_folder
if "%choice%"=="5" goto exit

echo Opzione non valida.
pause
goto :eof

:test_normal
echo.
echo Avvio test installazione normale...
echo NOTA: Richiederà privilegi di amministratore
echo.
pause
start DeskSRT_Installer.exe
goto exit

:test_silent
echo.
echo Avvio test installazione silenziosa...
echo NOTA: Installerà automaticamente senza interfaccia
echo.
set /p confirm="Sei sicuro? (s/n): "
if /i not "%confirm%"=="s" goto exit

echo Installazione silenziosa in corso...
DeskSRT_Installer.exe /S
echo.
echo Installazione silenziosa completata.
echo Controlla in C:\Program Files\DeskSRT
goto exit

:test_dryrun
echo.
echo Test verifica dipendenze...
echo.

REM Simula controllo dipendenze
echo Verificando Python...
python --version >nul 2>&1
if %errorlevel% == 0 (
    python --version
    echo Python: OK
) else (
    echo Python: NON TROVATO (sarà installato)
)

echo.
echo Verificando FFmpeg...
ffmpeg -version >nul 2>&1
if %errorlevel% == 0 (
    ffmpeg -version | findstr "ffmpeg version"
    echo FFmpeg: OK
) else (
    echo FFmpeg: NON TROVATO (sarà scaricato)
)

echo.
echo Verificando GPU NVIDIA...
nvidia-smi --query-gpu=name --format=csv,noheader >nul 2>&1
if %errorlevel% == 0 (
    nvidia-smi --query-gpu=name --format=csv,noheader
    echo GPU NVIDIA: OK
) else (
    echo GPU NVIDIA: NON RILEVATA
)

echo.
echo Verifica dipendenze completata.
goto exit

:open_folder
echo.
echo Apertura cartella installer...
explorer /select,DeskSRT_Installer.exe
goto exit

:exit
echo.
echo Test completato.
pause
