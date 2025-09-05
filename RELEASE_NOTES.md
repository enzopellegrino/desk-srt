# 🚀 Desk SRT v1.0.0 - Prima Release

**Desk SRT** è una potente applicazione desktop per Windows Server 2022 che cattura lo schermo intero e lo trasmette a server SRT usando accelerazione GPU NVENC.

## ✨ Caratteristiche Principali

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

## 📦 **Installer Professionale Incluso**

L'installer **DeskSRT_Installer.exe** fornisce:

### 🔧 **Installazione Automatica**
- ✅ **Controllo dipendenze** automatico (Python, FFmpeg, GPU NVIDIA)
- ✅ **Download Python 3.11** se non presente nel sistema
- ✅ **Download FFmpeg con NVENC** automatico
- ✅ **Installazione dipendenze Python** automatica
- ✅ **Configurazione PATH** e variabili ambiente

### 🎮 **Esperienza Utente Ottimale**
- ✅ **Interfaccia italiana** Modern UI
- ✅ **Installazione guidata** passo-passo
- ✅ **Shortcuts desktop** e menu Start
- ✅ **Uninstaller completo** integrato
- ✅ **Integrazione Windows** (Add/Remove Programs)

## 🛠️ **Requisiti di Sistema**

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

## 🚀 **Installazione Rapida**

1. **Scarica** `DeskSRT_Installer.exe` dalla release
2. **Esegui come amministratore** l'installer
3. **Segui** la procedura guidata (tutto automatico)
4. **Avvia** Desk SRT dal desktop o menu Start

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

## 🔧 **Uso dell'Applicazione**

1. **Avvia** Desk SRT (shortcut desktop o menu)
2. **Seleziona** endpoint SRT dal dropdown
3. **Clicca** "Avvia Streaming" 
4. **Monitora** lo stato nella GUI sempre visibile
5. **Ferma** quando necessario

## 🐛 **Risoluzione Problemi**

### **FFmpeg non trovato**
- L'installer dovrebbe scaricare FFmpeg automaticamente
- Verifica che `ffmpeg.exe` sia nella cartella di installazione

### **Errore NVENC**
- Controlla driver NVIDIA aggiornati
- Verifica GPU compatibile con NVENC
- Usa GPU-Z per confermare supporto hardware

### **Cattura schermo**
- Assicurati privilegi amministratore
- Disabilita antivirus temporaneamente se necessario
- Controlla che DirectShow sia disponibile

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

---

## 📞 **Supporto**

Per assistenza, problemi o richieste:
- **GitHub Issues**: [Segnala bug o richieste](https://github.com/enzopellegrino/desk-srt/issues)  
- **Documentazione**: README.md completo nel repository
- **Configurazione**: INSTALLER_README.md per dettagli installer

---

**Grazie per aver scelto Desk SRT! 🎉**
