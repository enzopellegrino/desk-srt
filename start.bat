@echo off
REM Desk SRT - Avvio rapido
REM Questo script avvia l'applicazione Desk SRT

title Desk SRT - Screen Capture to SRT

echo ================================
echo  Desk SRT - Avvio Applicazione
echo ================================
echo.

REM Controlla se siamo nella directory corretta
if not exist "desk_srt.py" (
    echo ERRORE: desk_srt.py non trovato!
    echo Assicurati di essere nella directory corretta
    pause
    exit /b 1
)

REM Controlla configurazione
if not exist "config\settings.ini" (
    echo ERRORE: File di configurazione non trovato!
    echo Esegui setup.bat prima del primo utilizzo
    pause
    exit /b 1
)

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
