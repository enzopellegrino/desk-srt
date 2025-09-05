@echo off
REM Desk SRT - Build Installer Script
REM Automatizza la creazione dell'installer NSIS

echo ================================
echo  Desk SRT - Installer Builder
echo ================================
echo.

REM Verifica NSIS
echo Verificando NSIS...
where makensis >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRORE: NSIS non trovato!
    echo.
    echo Installa NSIS da: https://nsis.sourceforge.io/Download
    echo Aggiungi NSIS al PATH di sistema
    echo.
    echo In alternativa, installa tramite:
    echo   winget install NSIS.NSIS
    echo   oppure
    echo   choco install nsis
    echo.
    pause
    exit /b 1
)

echo NSIS trovato: 
makensis /VERSION

echo.
REM Verifica file necessari
echo Verificando file del progetto...

set "missing_files="

if not exist "desk_srt.py" (
    set "missing_files=%missing_files% desk_srt.py"
)
if not exist "utils.py" (
    set "missing_files=%missing_files% utils.py"
)
if not exist "requirements.txt" (
    set "missing_files=%missing_files% requirements.txt"
)
if not exist "README.md" (
    set "missing_files=%missing_files% README.md"
)
if not exist "config\settings.ini" (
    set "missing_files=%missing_files% config\settings.ini"
)
if not exist "installer.nsi" (
    set "missing_files=%missing_files% installer.nsi"
)
if not exist "LICENSE.txt" (
    set "missing_files=%missing_files% LICENSE.txt"
)

if not "%missing_files%"=="" (
    echo ERRORE: File mancanti:%missing_files%
    echo.
    pause
    exit /b 1
)

echo Tutti i file necessari sono presenti.

echo.
REM Pulisci build precedenti
echo Pulizia build precedenti...
if exist "DeskSRT_Installer.exe" (
    del "DeskSRT_Installer.exe"
    echo Rimosso installer precedente
)

echo.
REM Crea icone predefinite se mancanti
if not exist "installer_icon.ico" (
    echo Creando icona predefinita...
    REM Crea un'icona semplice usando convert (se disponibile)
    where convert >nul 2>&1
    if %errorlevel% == 0 (
        convert -size 32x32 xc:blue -font Arial -pointsize 24 -fill white -gravity center -annotate +0+0 "SRT" installer_icon.ico 2>nul
    ) else (
        echo NOTA: installer_icon.ico non trovato. L'installer userà l'icona predefinita.
    )
)

if not exist "header.bmp" (
    echo NOTA: header.bmp non trovato. L'installer userà l'header predefinito.
)

echo.
REM Build dell'installer
echo Avvio build installer...
echo Comando: makensis installer.nsi
echo.

makensis installer.nsi

if %errorlevel% == 0 (
    echo.
    echo ================================
    echo  BUILD COMPLETATO CON SUCCESSO!
    echo ================================
    echo.
    
    if exist "DeskSRT_Installer.exe" (
        echo Installer creato: DeskSRT_Installer.exe
        
        REM Mostra dimensione file
        for %%I in (DeskSRT_Installer.exe) do (
            echo Dimensione: %%~zI bytes
        )
        
        echo.
        echo L'installer include:
        echo - Applicazione Desk SRT completa
        echo - Download automatico Python 3.11 (se necessario)
        echo - Download automatico FFmpeg con NVENC
        echo - Creazione collegamenti desktop e menu Start
        echo - Uninstaller completo
        echo.
        echo Per testare l'installer:
        echo   .\DeskSRT_Installer.exe
        echo.
        
        REM Opzione per avviare l'installer
        set /p run_installer="Vuoi testare l'installer ora? (s/n): "
        if /i "%run_installer%"=="s" (
            echo Avvio installer...
            start DeskSRT_Installer.exe
        )
        
    ) else (
        echo ERRORE: File installer non creato!
    )
) else (
    echo.
    echo ================================
    echo  ERRORE DURANTE IL BUILD!
    echo ================================
    echo.
    echo Controlla i messaggi di errore sopra.
    echo Verifica che tutti i file siano presenti e che
    echo lo script NSIS sia sintatticamente corretto.
)

echo.
pause
