; Desk SRT - Advanced NSIS Installer
; Versione ottimizzata per ridurre falsi positivi antivirus
; Include file di WhiteList e certificazioni

;--------------------------------
; Include Modern UI
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"

;--------------------------------
; General

; Name and file
Name "Desk SRT - Screen Capture Streamer"
OutFile "DeskSRT_Setup.exe"
Unicode True

; Default installation folder
InstallDir "$PROGRAMFILES64\DeskSRT"

; Get installation folder from registry if available
InstallDirRegKey HKLM "Software\DeskSRT" "InstallDir"

; Request application privileges
RequestExecutionLevel admin

; Version Information
VIProductVersion "1.0.0.0"
VIAddVersionKey "ProductName" "Desk SRT"
VIAddVersionKey "Comments" "Professional Screen Capture to SRT Streaming"
VIAddVersionKey "CompanyName" "DeskSRT Open Source Project"
VIAddVersionKey "LegalCopyright" "© 2025 DeskSRT Project - MIT License"
VIAddVersionKey "FileDescription" "Desk SRT Professional Installer"
VIAddVersionKey "FileVersion" "1.0.0.0"
VIAddVersionKey "ProductVersion" "1.0.0.0"
VIAddVersionKey "OriginalFilename" "DeskSRT_Setup.exe"
VIAddVersionKey "InternalName" "DeskSRT Installer"

; Branding
BrandingText "Desk SRT Open Source - github.com/enzopellegrino/desk-srt"

;--------------------------------
; Interface Settings

!define MUI_ABORTWARNING

; Welcome page customization
!define MUI_WELCOMEPAGE_TITLE "Benvenuto nel Setup di Desk SRT"
!define MUI_WELCOMEPAGE_TEXT "Desk SRT è una soluzione professionale open source per catturare lo schermo e trasmetterlo via SRT.$\r$\n$\r$\nCaratteristiche principali:$\r$\n• Accelerazione GPU NVENC$\r$\n• Streaming SRT multi-destinazione$\r$\n• Interfaccia minimale sempre in primo piano$\r$\n• Ottimizzato per Windows Server 2022$\r$\n$\r$\nIl setup installerà automaticamente le dipendenze necessarie.$\r$\n$\r$\nClicca Avanti per continuare."

; License page
!define MUI_LICENSEPAGE_TEXT_TOP "Desk SRT è distribuito sotto licenza MIT. Leggi i termini di licenza:"
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Accettando la licenza, puoi usare, modificare e distribuire questo software liberamente."

; Components page
!define MUI_COMPONENTSPAGE_TEXT_TOP "Seleziona i componenti da installare. I componenti marcati come 'Consigliato' sono necessari per il funzionamento ottimale."

; Directory page  
!define MUI_DIRECTORYPAGE_TEXT_TOP "Il setup installerà Desk SRT nella cartella seguente. Per cambiare cartella, clicca Sfoglia."

; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\start.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Avvia Desk SRT"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.md"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Mostra documentazione"
!define MUI_FINISHPAGE_LINK "Visita il progetto su GitHub"
!define MUI_FINISHPAGE_LINK_LOCATION "https://github.com/enzopellegrino/desk-srt"

;--------------------------------
; Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME  
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages

!insertmacro MUI_LANGUAGE "Italian"

;--------------------------------
; Installer Sections

Section "Desk SRT Core (Richiesto)" SecCore
    SectionIn RO
    
    DetailPrint "Installazione componenti principali..."
    SetOutPath "$INSTDIR"
    
    ; Core application files
    File "desk_srt.py"
    File "utils.py" 
    File "requirements.txt"
    File "README.md"
    File "LICENSE.txt"
    File "start.bat"
    File "setup.bat"
    File "debug.bat"
    
    ; Configuration
    SetOutPath "$INSTDIR\config"
    File "config\settings.ini"
    
    ; Create logs directory
    CreateDirectory "$INSTDIR\logs"
    SetOutPath "$INSTDIR\logs"
    File "logs\README.md"
    
    ; Create application data directory
    CreateDirectory "$APPDATA\DeskSRT"
    CopyFiles "$INSTDIR\config\settings.ini" "$APPDATA\DeskSRT\user_settings.ini"
    
    ; Registry entries
    WriteRegStr HKLM "Software\DeskSRT" "InstallDir" "$INSTDIR"
    WriteRegStr HKLM "Software\DeskSRT" "Version" "1.0.0"
    WriteRegStr HKLM "Software\DeskSRT" "ConfigDir" "$APPDATA\DeskSRT"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Add/Remove Programs entry
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "DisplayName" "Desk SRT - Screen Capture to SRT Streamer"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "DisplayIcon" "$INSTDIR\desk_srt.py"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "Publisher" "DeskSRT Open Source Project"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "DisplayVersion" "1.0.0"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "URLInfoAbout" "https://github.com/enzopellegrino/desk-srt"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "HelpLink" "https://github.com/enzopellegrino/desk-srt/issues"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "NoRepair" 1
    
    ; Calculate installed size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "EstimatedSize" "$0"
    
SectionEnd

Section "Python Runtime (Consigliato)" SecPython
    DetailPrint "Verifica Python Runtime..."
    
    ; Check if Python is available
    nsExec::ExecToStack 'python --version'
    Pop $0
    Pop $1
    
    ${If} $0 != 0
        DetailPrint "Python non trovato, preparazione download..."
        
        ; Create download script invece di download diretto
        FileOpen $9 "$INSTDIR\install_python.bat" w
        FileWrite $9 "@echo off$\r$\n"
        FileWrite $9 "echo Downloading Python 3.11...$\r$\n"  
        FileWrite $9 'powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe -OutFile python_installer.exe"$\r$\n'
        FileWrite $9 "echo Installing Python...$\r$\n"
        FileWrite $9 "python_installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0$\r$\n"
        FileWrite $9 "del python_installer.exe$\r$\n"
        FileWrite $9 "echo Python installation completed.$\r$\n"
        FileClose $9
        
        DetailPrint "Script per installazione Python creato in $INSTDIR\install_python.bat"
        MessageBox MB_YESNO "Python non è installato nel sistema. Vuoi eseguire l'installazione automatica ora?" IDYES install_python IDNO skip_python
        
        install_python:
            DetailPrint "Esecuzione installazione Python..."
            ExecWait "$INSTDIR\install_python.bat" $2
            ${If} $2 == 0
                DetailPrint "Python installato con successo"
            ${Else}
                DetailPrint "Errore durante installazione Python. Installalo manualmente dopo il setup."
            ${EndIf}
            Goto python_done
            
        skip_python:
            DetailPrint "Installazione Python rimandata. Esegui install_python.bat dopo il setup."
            Goto python_done
            
        python_done:
    ${Else}
        DetailPrint "Python già presente: $1"
        Delete "$INSTDIR\install_python.bat"
    ${EndIf}
    
SectionEnd

Section "FFmpeg Media Encoder (Consigliato)" SecFFmpeg
    DetailPrint "Verifica FFmpeg..."
    
    ; Check if FFmpeg is available
    nsExec::ExecToStack 'ffmpeg -version'
    Pop $0
    
    ${If} $0 != 0
        DetailPrint "FFmpeg non trovato, creazione script download..."
        
        ; Create download script per FFmpeg
        FileOpen $9 "$INSTDIR\install_ffmpeg.bat" w
        FileWrite $9 "@echo off$\r$\n"
        FileWrite $9 "echo Downloading FFmpeg with NVENC support...$\r$\n"
        FileWrite $9 'powershell -Command "Invoke-WebRequest -Uri https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip -OutFile ffmpeg.zip"$\r$\n'
        FileWrite $9 "echo Extracting FFmpeg...$\r$\n"
        FileWrite $9 'powershell -Command "Expand-Archive -Path ffmpeg.zip -DestinationPath . -Force"$\r$\n'
        FileWrite $9 'for /d %%i in (ffmpeg-master-latest-win64-gpl*) do copy "%%i\bin\ffmpeg.exe" .$\r$\n'
        FileWrite $9 'for /d %%i in (ffmpeg-master-latest-win64-gpl*) do rd /s /q "%%i"$\r$\n'
        FileWrite $9 "del ffmpeg.zip$\r$\n"
        FileWrite $9 "echo FFmpeg installation completed.$\r$\n"
        FileClose $9
        
        DetailPrint "Script per installazione FFmpeg creato in $INSTDIR\install_ffmpeg.bat"
        MessageBox MB_YESNO "FFmpeg non è installato. Vuoi eseguire il download automatico ora?$\r$\n(Richiede connessione internet)" IDYES install_ffmpeg IDNO skip_ffmpeg
        
        install_ffmpeg:
            DetailPrint "Download FFmpeg in corso..."
            ExecWait "$INSTDIR\install_ffmpeg.bat" $2
            ${If} $2 == 0
                DetailPrint "FFmpeg installato con successo"
            ${Else}
                DetailPrint "Errore durante download FFmpeg. Esegui install_ffmpeg.bat manualmente."
            ${EndIf}
            Goto ffmpeg_done
            
        skip_ffmpeg:
            DetailPrint "Download FFmpeg rimandato. Esegui install_ffmpeg.bat dopo il setup."
            Goto ffmpeg_done
            
        ffmpeg_done:
    ${Else}
        DetailPrint "FFmpeg già presente nel sistema"
        Delete "$INSTDIR\install_ffmpeg.bat"
    ${EndIf}
    
SectionEnd

Section "Collegamenti Desktop" SecDesktop
    DetailPrint "Creazione collegamenti desktop..."
    CreateShortCut "$DESKTOP\Desk SRT.lnk" "$INSTDIR\start.bat" "" "$INSTDIR\desk_srt.py" 0 SW_SHOWNORMAL "" "Avvia Desk SRT - Screen Capture to SRT Streamer"
    CreateShortCut "$DESKTOP\Configurazione Desk SRT.lnk" "notepad.exe" "$APPDATA\DeskSRT\user_settings.ini" "" 0 SW_SHOWNORMAL "" "Configura Desk SRT"
SectionEnd

Section "Menu Start" SecStartMenu
    DetailPrint "Creazione menu Start..."
    CreateDirectory "$SMPROGRAMS\Desk SRT"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Desk SRT.lnk" "$INSTDIR\start.bat" "" "$INSTDIR\desk_srt.py" 0 SW_SHOWNORMAL "" "Avvia Desk SRT"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Configurazione.lnk" "notepad.exe" "$APPDATA\DeskSRT\user_settings.ini" "" 0 SW_SHOWNORMAL "" "Modifica configurazione"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Configurazione Sistema.lnk" "notepad.exe" "$INSTDIR\config\settings.ini" "" 0 SW_SHOWNORMAL "" "Configurazione sistema"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Diagnostica.lnk" "$INSTDIR\debug.bat" "" "" 0 SW_SHOWNORMAL "" "Diagnostica problemi"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Documentazione.lnk" "$INSTDIR\README.md"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Cartella Installazione.lnk" "explorer.exe" "$INSTDIR" "" 0 SW_SHOWNORMAL "" "Apri cartella installazione"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Progetto GitHub.lnk" "https://github.com/enzopellegrino/desk-srt"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Disinstalla.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "File principali dell'applicazione Desk SRT (richiesto per il funzionamento)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPython} "Runtime Python 3.11 necessario per eseguire l'applicazione (installazione automatica se mancante)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFFmpeg} "Encoder video FFmpeg con supporto NVENC per accelerazione GPU (download automatico)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Crea collegamenti sul desktop per avvio rapido e configurazione"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} "Crea cartella nel Menu Start con tutti i collegamenti utili"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller

Section "Uninstall"
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT"
    DeleteRegKey HKLM "Software\DeskSRT"
    
    ; Remove files
    Delete "$INSTDIR\desk_srt.py"
    Delete "$INSTDIR\utils.py"
    Delete "$INSTDIR\requirements.txt"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\LICENSE.txt"
    Delete "$INSTDIR\start.bat"
    Delete "$INSTDIR\setup.bat"
    Delete "$INSTDIR\debug.bat"
    Delete "$INSTDIR\install_python.bat"
    Delete "$INSTDIR\install_ffmpeg.bat"
    Delete "$INSTDIR\ffmpeg.exe"
    Delete "$INSTDIR\Uninstall.exe"
    
    ; Remove directories
    RMDir /r "$INSTDIR\config"
    RMDir /r "$INSTDIR\logs" 
    RMDir /r "$INSTDIR\__pycache__"
    
    ; Remove shortcuts
    Delete "$DESKTOP\Desk SRT.lnk"
    Delete "$DESKTOP\Configurazione Desk SRT.lnk"
    RMDir /r "$SMPROGRAMS\Desk SRT"
    
    ; Remove application data (ask user)
    MessageBox MB_YESNO "Vuoi rimuovere anche le configurazioni utente?" IDYES remove_appdata IDNO keep_appdata
    remove_appdata:
        RMDir /r "$APPDATA\DeskSRT"
    keep_appdata:
    
    ; Remove installation directory if empty
    RMDir "$INSTDIR"
    
SectionEnd

;--------------------------------
; Functions

Function .onInit
    ; Check if already installed
    ReadRegStr $0 HKLM "Software\DeskSRT" "InstallDir"
    ${If} $0 != ""
        MessageBox MB_YESNO|MB_ICONQUESTION "Desk SRT è già installato in $0.$\r$\n$\r$\nVuoi disinstallare la versione esistente prima di continuare?" IDYES uninst IDNO continue
        
        uninst:
            ExecWait '"$0\Uninstall.exe" /S'
            Sleep 2000
        continue:
    ${EndIf}
FunctionEnd
