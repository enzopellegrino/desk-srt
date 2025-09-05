# �️ Desk SRT v1.1.0 - Installer Anti-Virus Ottimizzato

**Aggiornamento importante**: Risolti i problemi di falsi positivi con antivirus grazie al nuovo installer ottimizzato.

## 🆕 Novità v1.1.0

### 🛡️ **Installer Anti-Falsi Positivi**
- **Nuovo DeskSRT_Setup.exe** (117KB) ottimizzato per ridurre rilevazioni antivirus
- **Metadati professionali** completi (company, copyright, versioni)
- **Download differito**: Crea script invece di scaricare automaticamente
- **Trasparenza totale**: Ogni azione spiegata e con conferma utente
- **Branding open source**: Riferimenti GitHub per verificabilità

### 🔧 **Miglioramenti Tecnici**
- **Due versioni installer**: Setup (sicuro) e Installer (automatico)
- **Script di installazione separati** per Python e FFmpeg
- **Configurazione utente** in AppData per impostazioni personalizzate
- **Uninstaller migliorato** con opzione mantieni configurazioni
- **Collegamenti desktop** e menu Start ottimizzati

### 📦 **Installer Disponibili**

| File | Dimensione | Strategia | Raccomandato per |
|------|------------|-----------|------------------|
| **DeskSRT_Setup.exe** | 117KB | Anti-falsi positivi | **Uso aziendale/generale** |
| **DeskSRT_Installer.exe** | 128KB | Download automatico | Utenti tecnici |

## ✨ Caratteristiche Principali (da v1.0.0)

### 🎯 **Cattura Schermo Professionale**
- **Accelerazione GPU NVENC** per encoding hardware ad alte prestazioni
- **Cattura schermo completa** ottimizzata per Windows Server 2022  
- **Bassa latenza** per streaming in tempo reale
- **DirectShow integration** per massima compatibilità

### 🔗 **Streaming SRT Multi-Destinazione**
- **Supporto SRT nativo** per trasmissione affidabile
- **Configurazione multi-endpoint** (es. `srt://direct-obs4.wyscout.com:10080`, `10081`)
- **Gestione automatica riconnessione** in caso di interruzioni
- **Monitoraggio stato** in tempo reale

### 🖥️ **Interfaccia Utente Minimale**
- **GUI sempre in primo piano** che non interferisce con la cattura
- **Posizionamento intelligente** nell'angolo superiore destro
- **Controlli intuitivi** per avvio/stop streaming
- **Indicatori di stato** visivi e informativi

### ⚙️ **Configurazione Avanzata**
- **File INI** per personalizzazione completa
- **Preset NVENC** ottimizzati per diverse qualità
- **Bitrate e FPS** configurabili
- **Profili encoding** multipli

## ️ **Requisiti di Sistema**

### **Minimi:**
- Windows Server 2022 o Windows 10/11 x64
- Python 3.8+ (installato automaticamente)
- 4GB RAM
- 500MB spazio disco

### **Consigliati:**
- GPU NVIDIA con supporto NVENC (GTX 1050+, RTX series)
- Driver NVIDIA aggiornati
- 8GB RAM per streaming ad alta qualità
- Connessione internet stabile per streaming SRT

## 🚀 **Installazione Sicura**

### **Metodo Consigliato (DeskSRT_Setup.exe):**
1. **Scarica** `DeskSRT_Setup.exe` dalla release
2. **Esegui come amministratore** (nessun falso positivo)
3. **Seleziona componenti** da installare
4. **Conferma** installazione dipendenze quando richiesto
5. **Avvia** dal desktop o menu Start

### **Processo Sicuro:**
- ✅ **Nessun download automatico** durante installazione
- ✅ **Script verificabili** creati in cartella installazione
- ✅ **Controllo utente** su ogni dipendenza
- ✅ **Link GitHub** per verifica codice sorgente

## 📋 **Configurazione Default**

L'applicazione viene preconfigurata con:

```ini
[SRT_ENDPOINTS]
endpoints = srt://direct-obs4.wyscout.com:10080,srt://direct-obs4.wyscout.com:10081

[VIDEO_SETTINGS]
fps = 30
bitrate = 2000000
resolution = 1920x1080

[ENCODER_SETTINGS]
codec = h264_nvenc
preset = fast
profile = high
```

## 🔧 **Post-Installazione**

Dopo l'installazione:

1. **Esegui script dipendenze**:
   - `install_python.bat` (se Python non presente)
   - `install_ffmpeg.bat` (per FFmpeg con NVENC)

2. **Verifica configurazione**:
   - Apri configurazione dal menu Start
   - Modifica endpoint SRT se necessario

3. **Test applicazione**:
   - Avvia Desk SRT dal desktop
   - Verifica rilevamento GPU NVIDIA
   - Test streaming su endpoint di prova

## 🐛 **Risoluzione Problemi**

### **Antivirus blocca installer**
- ✅ **Usa DeskSRT_Setup.exe** (ottimizzato anti-falsi positivi)
- ✅ **Aggiungi eccezione** per cartella installazione se necessario
- ✅ **Verifica su VirusTotal** per conferma sicurezza

### **FFmpeg non trovato**
- Esegui `install_ffmpeg.bat` dalla cartella installazione
- Verifica download completato correttamente
- Controlla che `ffmpeg.exe` sia nella cartella app

### **Errore NVENC**
- Aggiorna driver NVIDIA alla versione più recente
- Verifica GPU compatibile con [NVENC Support Matrix](https://developer.nvidia.com/video-encode-and-decode-gpu-support-matrix-new)
- Usa GPU-Z per verificare supporto hardware

### **Python non riconosciuto**
- Esegui `install_python.bat` come amministratore
- Riavvia sistema dopo installazione Python
- Verifica PATH con `python --version` in cmd

## 📈 **Performance**

- **Latenza**: < 100ms in condizioni ottimali
- **CPU Usage**: Minimo grazie ad accelerazione GPU
- **Memoria**: ~50-100MB durante streaming
- **Qualità**: Fino a 1080p60 con bitrate configurabile

## 🔮 **Roadmap Future**

- Support per streaming multipli simultanei  
- Integrazione OBS Studio plugin
- Support codec AV1 con encoder AV1
- Interfaccia web per controllo remoto
- Statistiche avanzate e logging
- Firma digitale installer per zero falsi positivi

---

## 📞 **Supporto**

Per assistenza, problemi o richieste:
- **GitHub Issues**: [Segnala bug o richieste](https://github.com/enzopellegrino/desk-srt/issues)  
- **Documentazione**: README.md completo nel repository
- **Configurazione**: INSTALLER_README.md per dettagli installer

---

**Grazie per aver scelto Desk SRT! 🎉**

*Versione 1.1.0 - Sicurezza e affidabilità migliorate*
