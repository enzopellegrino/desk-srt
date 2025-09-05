# Desk SRT - Installer NSIS

Questo progetto include un installer professionale creato con **NSIS** (Nullsoft Scriptable Install System) per una distribuzione semplice e completa dell'applicazione Desk SRT.

## 🚀 Caratteristiche dell'Installer

### ✅ **Installazione Completa Automatica**
- **Interfaccia moderna** con Modern UI 2
- **Controllo dipendenze** automatico (Python, FFmpeg, GPU NVIDIA)
- **Download automatico** di Python 3.11 se non presente
- **Download automatico** di FFmpeg con supporto NVENC
- **Installazione silenziosa** delle dipendenze Python

### 🎯 **Componenti Installabili**
1. **Desk SRT (Richiesto)** - Applicazione principale
2. **Python 3.11** - Runtime Python (se non presente)
3. **FFmpeg con NVENC** - Encoder video con accelerazione GPU
4. **Collegamento Desktop** - Shortcut sul desktop
5. **Menu Start** - Cartella nel menu Start con collegamenti

### 🔧 **Funzionalità Avanzate**
- **Uninstaller completo** con rimozione di tutti i file e registry
- **Integrazione Windows** (Add/Remove Programs)
- **Controllo versioni** - Rimozione automatica versioni precedenti
- **Validazione sistema** - Verifica GPU NVIDIA e dipendenze
- **Installazione per tutti gli utenti** con privilegi amministratore

## 📋 **Requisiti per Creare l'Installer**

### Software Necessario:
```bash
# NSIS (Nullsoft Scriptable Install System)
winget install NSIS.NSIS
# oppure
choco install nsis
# oppure scaricare da: https://nsis.sourceforge.io/Download
```

### File Richiesti:
- `installer.nsi` - Script principale NSIS
- `desk_srt.py` - Applicazione principale
- `utils.py` - Utilità
- `requirements.txt` - Dipendenze Python
- `README.md` - Documentazione
- `LICENSE.txt` - Licenza
- `config/settings.ini` - Configurazione predefinita
- `installer_icon.ico` - Icona installer (opzionale)
- `header.bmp` - Header grafico (opzionale)

## 🛠️ **Come Creare l'Installer**

### Metodo Automatico:
```bash
# Esegui lo script di build
build_installer.bat
```

### Metodo Manuale:
```bash
# Verifica NSIS
makensis /VERSION

# Compila l'installer
makensis installer.nsi
```

## 📦 **Risultato**

L'installer generato (`DeskSRT_Installer.exe`) include:

- **Dimensione**: ~15-20 MB (senza dipendenze)
- **Lingua**: Italiano
- **Compatibilità**: Windows 10/11, Windows Server 2022
- **Architettura**: x64
- **Privilegi**: Richiede amministratore

## 🎮 **Uso dell'Installer**

### Per l'utente finale:
1. **Scarica** `DeskSRT_Installer.exe`
2. **Esegui come amministratore**
3. **Segui** le istruzioni guidate
4. **Seleziona** i componenti da installare
5. **Attendi** il download automatico delle dipendenze
6. **Avvia** Desk SRT dal desktop o menu Start

### Opzioni di installazione:
- **Standard**: Tutto tranne Python (se già presente)
- **Completa**: Tutti i componenti incluso Python
- **Personalizzata**: Selezione manuale componenti
- **Minima**: Solo applicazione base

## 🔄 **Disinstallazione**

L'installer crea un uninstaller completo che:
- **Rimuove** tutti i file installati
- **Pulisce** le chiavi di registro
- **Elimina** collegamenti e menu
- **Mantiene** i file di configurazione utente (opzionale)

Accessibile da:
- **Add/Remove Programs** in Windows
- **Menu Start** → Desk SRT → Disinstalla
- **Cartella installazione** → `Uninstall.exe`

## 🛡️ **Sicurezza**

- **Certificazione**: L'installer può essere firmato digitalmente
- **SmartScreen**: Riconosciuto come software affidabile dopo firma
- **Antivirus**: Falsi positivi minimizzati con esclusioni specifiche
- **Privilegi**: Richiede amministratore solo per installazione sistema

## 📝 **Personalizzazione**

### Modificare l'installer:
1. **Edita** `installer.nsi` per cambiare testi, percorsi, componenti
2. **Sostituisci** `installer_icon.ico` per icona personalizzata
3. **Sostituisci** `header.bmp` per grafica personalizzata
4. **Modifica** sezioni di licenza e descrizioni

### Branding personalizzato:
- Company name nelle proprietà file
- Logo e grafica personalizzata
- Testi e messaggi localizzati
- URL di supporto e aggiornamenti
