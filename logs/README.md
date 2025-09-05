# Directory per i file di log dell'applicazione Desk SRT
# I log vengono generati automaticamente durante l'esecuzione

## Struttura dei log:
- `desk_srt_YYYYMMDD.log` - Log giornalieri dell'applicazione
- Rotazione automatica per data
- Include informazioni di debug, errori e stato streaming

## Livelli di log:
- **INFO**: Operazioni normali (avvio/stop streaming)
- **WARNING**: Situazioni di attenzione
- **ERROR**: Errori che non bloccano l'applicazione
- **DEBUG**: Informazioni dettagliate per troubleshooting

Mantieni questa directory per il corretto funzionamento del logging.
