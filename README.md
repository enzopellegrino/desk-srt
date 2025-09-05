# Desk SRT - Screen Capture to SRT Application

Una piccola applicazione desktop per Windows Server 2022 che cattura lo schermo intero e lo trasmette a server SRT usando FFmpeg con accelerazione GPU.

## Caratteristiche

- **Cattura schermo completa** con accelerazione GPU (NVENC)
- **Trasmissione SRT in tempo reale** a più destinazioni
- **Interfaccia minimale** sempre in primo piano
- **Ottimizzato per Windows Server 2022**
- **Basso utilizzo risorse** grazie all'accelerazione hardware

## Requisiti

- Windows Server 2022
- Python 3.8+
- FFmpeg con supporto NVENC
- Scheda video NVIDIA con supporto NVENC
- DirectShow support

## Installazione

1. **Clona il repository:**
   ```bash
   git clone <repository-url>
   cd desk-srt
   ```

2. **Installa le dipendenze Python:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Installa FFmpeg:**
   - Scarica FFmpeg con supporto NVENC da https://ffmpeg.org/download.html#build-windows
   - Estrai e aggiungi `ffmpeg.exe` al PATH o nella cartella del progetto
   - Verifica l'installazione: `ffmpeg -version`

4. **Configura gli endpoint SRT:**
   - Modifica `config/settings.ini` con i tuoi endpoint SRT
   - Esempio: `srt://direct-obs4.wyscout.com:10080`

## Utilizzo

Avvia l'applicazione:
```bash
python desk_srt.py
```

L'applicazione mostrerà una piccola finestra sempre in primo piano con controlli per:
- Avviare/fermare la cattura
- Selezionare gli endpoint SRT
- Monitorare lo stato della trasmissione

## Configurazione

Modifica `config/settings.ini` per personalizzare:
- Endpoint SRT
- Qualità video (bitrate, FPS)
- Impostazioni encoder NVENC
- Dimensioni finestra GUI

## Note Tecniche

- Utilizza NVENC per encoding hardware accelerato
- DirectShow per cattura schermo su Windows
- Latenza ottimizzata per streaming in tempo reale
- Supporto multi-destinazione SRT

## Risoluzione Problemi

- **FFmpeg non trovato**: Verifica che `ffmpeg.exe` sia nel PATH
- **Errore NVENC**: Controlla che la GPU NVIDIA supporti NVENC
- **Cattura schermo**: Assicurati che l'app abbia permessi di cattura schermo
