# Desk SRT Installer Placeholder

Questo file rappresenta l'installer `DeskSRT_Installer.exe` che verrà creato su Windows.

## Per creare l'installer su Windows:

1. Installa NSIS:
   ```bash
   winget install NSIS.NSIS
   ```

2. Esegui lo script di build:
   ```bash
   build_installer.bat
   ```

3. L'installer `DeskSRT_Installer.exe` verrà generato automaticamente.

## Contenuto dell'installer:
- Applicazione Desk SRT completa
- Download automatico Python 3.11 (se necessario)
- Download automatico FFmpeg con NVENC
- Creazione collegamenti desktop e menu Start
- Uninstaller completo

## Dimensione prevista: ~15-20 MB
## Compatibilità: Windows 10/11, Windows Server 2022 x64
