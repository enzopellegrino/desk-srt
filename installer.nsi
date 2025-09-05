; Desk SRT - NSIS Installer Script
; Screen Capture to SRT Streaming Application
; Optimized for Windows Server 2022

;--------------------------------
; Include Modern UI
!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"

;--------------------------------
; General

; Name and file
Name "Desk SRT - Screen Capture to SRT Streamer"
OutFile "DeskSRT_Installer.exe"
Unicode True

; Default installation folder
InstallDir "$PROGRAMFILES64\DeskSRT"

; Get installation folder from registry if available
InstallDirRegKey HKLM "Software\DeskSRT" "InstallDir"

; Request application privileges for Windows Vista/7/8/10/11
RequestExecutionLevel admin

; Version Information
VIVersionInfo /LANG=${LANG_ITALIAN} /CODEPAGE=1252
VIProductVersion "1.0.0.0"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "ProductName" "Desk SRT"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "Comments" "Screen Capture to SRT Streaming"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "CompanyName" "DeskSRT Project"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "LegalCopyright" "© 2025 DeskSRT Project"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "FileDescription" "Desk SRT Installer"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "FileVersion" "1.0.0.0"
VIAddVersionKey /LANG=${LANG_ITALIAN} /CODEPAGE=1252 "ProductVersion" "1.0.0.0"

;--------------------------------
; Interface Settings

!define MUI_ABORTWARNING
!define MUI_ICON "installer_icon.ico"
!define MUI_UNICON "installer_icon.ico"

; Header image
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "header.bmp"
!define MUI_HEADERIMAGE_RIGHT

; Welcome page
!define MUI_WELCOMEPAGE_TITLE "Benvenuto nell'installer di Desk SRT"
!define MUI_WELCOMEPAGE_TEXT "Questo programma installerà Desk SRT sul tuo computer.$\r$\n$\r$\nDesk SRT è un'applicazione per catturare lo schermo e trasmetterlo via SRT usando accelerazione GPU NVENC.$\r$\n$\r$\nFai clic su Avanti per continuare."

; License page
!define MUI_LICENSEPAGE_TEXT_TOP "Leggi attentamente i termini di licenza prima di installare Desk SRT."
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Se accetti tutti i termini dell'accordo, seleziona Accetto per continuare. Devi accettare l'accordo per installare Desk SRT."

; Components page
!define MUI_COMPONENTSPAGE_TEXT_TOP "Seleziona i componenti da installare. Fai clic su Avanti per continuare."

; Directory page
!define MUI_DIRECTORYPAGE_TEXT_TOP "L'installer installerà Desk SRT nella cartella seguente. Per installare in una cartella diversa, fai clic su Sfoglia e seleziona un'altra cartella. Fai clic su Avanti per continuare."

; Finish page
!define MUI_FINISHPAGE_RUN "$INSTDIR\start.bat"
!define MUI_FINISHPAGE_RUN_TEXT "Avvia Desk SRT"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.md"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Mostra README"

;--------------------------------
; Pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

; Custom page for Python installation check
Page custom PythonCheckPage PythonCheckPageLeave

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
; Variables

Var PythonPath
Var PythonVersion
Var FFmpegPath
Var NeedsPython
Var NeedsFFmpeg

;--------------------------------
; Custom Python Check Page

Function PythonCheckPage
    !insertmacro MUI_HEADER_TEXT "Controllo Dipendenze" "Verifica della presenza di Python e FFmpeg"
    
    nsDialogs::Create 1018
    Pop $0
    
    ${NSD_CreateLabel} 0 0 100% 20u "Controllo delle dipendenze necessarie per Desk SRT..."
    Pop $0
    
    ; Check Python
    ${NSD_CreateLabel} 0 30u 100% 15u "• Python 3.8+:"
    Pop $0
    
    ClearErrors
    ExecWait 'python --version' $1
    ${If} ${Errors}
    ${OrIf} $1 != 0
        ${NSD_CreateLabel} 150u 30u 100% 15u "NON TROVATO (sarà installato)"
        Pop $0
        ${NSD_SetColor} $0 0xFF0000
        StrCpy $NeedsPython "1"
    ${Else}
        nsExec::ExecToStack 'python --version'
        Pop $1
        Pop $PythonVersion
        ${NSD_CreateLabel} 150u 30u 100% 15u "TROVATO ($PythonVersion)"
        Pop $0
        ${NSD_SetColor} $0 0x008000
        StrCpy $NeedsPython "0"
    ${EndIf}
    
    ; Check FFmpeg
    ${NSD_CreateLabel} 0 50u 100% 15u "• FFmpeg con NVENC:"
    Pop $0
    
    ClearErrors
    ExecWait 'ffmpeg -version' $1
    ${If} ${Errors}
    ${OrIf} $1 != 0
        ${NSD_CreateLabel} 150u 50u 100% 15u "NON TROVATO (sarà scaricato)"
        Pop $0
        ${NSD_SetColor} $0 0xFF0000
        StrCpy $NeedsFFmpeg "1"
    ${Else}
        ${NSD_CreateLabel} 150u 50u 100% 15u "TROVATO"
        Pop $0
        ${NSD_SetColor} $0 0x008000
        StrCpy $NeedsFFmpeg "0"
    ${EndIf}
    
    ; GPU Check
    ${NSD_CreateLabel} 0 70u 100% 15u "• GPU NVIDIA:"
    Pop $0
    
    ClearErrors
    ExecWait 'nvidia-smi --query-gpu=name --format=csv,noheader' $1
    ${If} ${Errors}
    ${OrIf} $1 != 0
        ${NSD_CreateLabel} 150u 70u 100% 15u "NON RILEVATA"
        Pop $0
        ${NSD_SetColor} $0 0xFF8000
    ${Else}
        ${NSD_CreateLabel} 150u 70u 100% 15u "RILEVATA"
        Pop $0
        ${NSD_SetColor} $0 0x008000
    ${EndIf}
    
    nsDialogs::Show
FunctionEnd

Function PythonCheckPageLeave
FunctionEnd

;--------------------------------
; Installer Sections

Section "Desk SRT (Richiesto)" SecMain
    SectionIn RO
    
    SetOutPath "$INSTDIR"
    
    ; Copy main application files
    File "desk_srt.py"
    File "utils.py"
    File "requirements.txt"
    File "README.md"
    File "start.bat"
    
    ; Copy configuration
    SetOutPath "$INSTDIR\config"
    File "config\settings.ini"
    
    ; Create logs directory
    CreateDirectory "$INSTDIR\logs"
    
    ; Install Python dependencies if Python is available
    ${If} $NeedsPython == "0"
        DetailPrint "Installazione dipendenze Python..."
        ExecWait '"python" -m pip install -r "$INSTDIR\requirements.txt"' $0
        ${If} $0 != 0
            MessageBox MB_ICONEXCLAMATION "Errore installando le dipendenze Python. Installale manualmente dopo l'installazione."
        ${EndIf}
    ${EndIf}
    
    ; Store installation folder
    WriteRegStr HKLM "Software\DeskSRT" "InstallDir" "$INSTDIR"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Add to Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "DisplayName" "Desk SRT"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "DisplayIcon" "$INSTDIR\desk_srt.py"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "Publisher" "DeskSRT Project"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "DisplayVersion" "1.0.0"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "NoRepair" 1
    
    ; Calculate installed size
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT" "EstimatedSize" "$0"
    
SectionEnd

Section "Python 3.11" SecPython
    ${If} $NeedsPython == "1"
        DetailPrint "Download Python 3.11..."
        
        ; Download Python installer
        NSISdl::download "https://www.python.org/ftp/python/3.11.7/python-3.11.7-amd64.exe" "$TEMP\python_installer.exe"
        Pop $R0
        
        ${If} $R0 == "success"
            DetailPrint "Installazione Python..."
            ExecWait '"$TEMP\python_installer.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0' $0
            
            ${If} $0 == 0
                DetailPrint "Python installato con successo"
                ; Install dependencies
                ExecWait '"python" -m pip install -r "$INSTDIR\requirements.txt"'
            ${Else}
                MessageBox MB_ICONEXCLAMATION "Errore durante l'installazione di Python. Installalo manualmente."
            ${EndIf}
            
            Delete "$TEMP\python_installer.exe"
        ${Else}
            MessageBox MB_ICONEXCLAMATION "Errore scaricando Python. Connessione internet richiesta."
        ${EndIf}
    ${EndIf}
SectionEnd

Section "FFmpeg con NVENC" SecFFmpeg
    ${If} $NeedsFFmpeg == "1"
        DetailPrint "Download FFmpeg..."
        
        ; Download FFmpeg
        NSISdl::download "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" "$TEMP\ffmpeg.zip"
        Pop $R0
        
        ${If} $R0 == "success"
            DetailPrint "Estrazione FFmpeg..."
            
            ; Extract FFmpeg
            nsisunz::Unzip "$TEMP\ffmpeg.zip" "$TEMP\"
            
            ; Find and copy ffmpeg.exe
            FindFirst $0 $1 "$TEMP\ffmpeg-master-latest-win64-gpl*"
            ${If} $0 != ""
                CopyFiles "$TEMP\$1\bin\ffmpeg.exe" "$INSTDIR\"
                DetailPrint "FFmpeg installato in $INSTDIR"
                
                ; Cleanup
                RMDir /r "$TEMP\$1"
                FindClose $0
            ${EndIf}
            
            Delete "$TEMP\ffmpeg.zip"
        ${Else}
            MessageBox MB_ICONEXCLAMATION "Errore scaricando FFmpeg. Connessione internet richiesta."
        ${EndIf}
    ${EndIf}
SectionEnd

Section "Collegamento Desktop" SecDesktop
    CreateShortCut "$DESKTOP\Desk SRT.lnk" "$INSTDIR\start.bat" "" "$INSTDIR\desk_srt.py" 0
SectionEnd

Section "Menu Start" SecStartMenu
    CreateDirectory "$SMPROGRAMS\Desk SRT"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Desk SRT.lnk" "$INSTDIR\start.bat" "" "$INSTDIR\desk_srt.py" 0
    CreateShortCut "$SMPROGRAMS\Desk SRT\Configurazione.lnk" "$INSTDIR\config\settings.ini"
    CreateShortCut "$SMPROGRAMS\Desk SRT\README.lnk" "$INSTDIR\README.md"
    CreateShortCut "$SMPROGRAMS\Desk SRT\Disinstalla.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; Descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMain} "File principali dell'applicazione Desk SRT (richiesto)"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecPython} "Installa Python 3.11 se non presente nel sistema"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFFmpeg} "Scarica e installa FFmpeg con supporto NVENC"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} "Crea collegamento sul desktop"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} "Crea menu nel Menu Start"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
; Uninstaller

Section "Uninstall"
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\DeskSRT"
    DeleteRegKey HKLM "Software\DeskSRT"
    
    ; Remove files and directories
    Delete "$INSTDIR\desk_srt.py"
    Delete "$INSTDIR\utils.py"
    Delete "$INSTDIR\requirements.txt"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\start.bat"
    Delete "$INSTDIR\ffmpeg.exe"
    Delete "$INSTDIR\Uninstall.exe"
    
    RMDir /r "$INSTDIR\config"
    RMDir /r "$INSTDIR\logs"
    RMDir /r "$INSTDIR\__pycache__"
    
    ; Remove shortcuts
    Delete "$DESKTOP\Desk SRT.lnk"
    RMDir /r "$SMPROGRAMS\Desk SRT"
    
    ; Remove installation directory if empty
    RMDir "$INSTDIR"
    
SectionEnd

;--------------------------------
; Functions

Function .onInit
    ; Check if already installed
    ReadRegStr $0 HKLM "Software\DeskSRT" "InstallDir"
    ${If} $0 != ""
        MessageBox MB_YESNO|MB_ICONQUESTION "Desk SRT è già installato in $0.$\r$\nVuoi disinstallare la versione esistente?" IDYES uninst
        Abort
        
        uninst:
        ExecWait '"$0\Uninstall.exe" /S'
    ${EndIf}
FunctionEnd

Function .onGUIEnd
FunctionEnd
