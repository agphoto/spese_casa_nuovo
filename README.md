# Quanto Spendo? — `spese_casa_nuovo`

App Flutter per tenere traccia di **entrate e uscite domestiche**, con
categorie, statistiche e backup/restore (remoto e locale).

Versione: **5.0**

## Funzionalità

- **Movimenti**: inserimento/modifica/eliminazione di entrate e uscite, con
  categoria, data/ora, descrizione e importo.
- **Lista** con ricerca per descrizione, totale in evidenza (mascherabile con
  l'occhietto 👁) e pull-to-refresh.
- **Filtri rapidi**: _Tutto_, _Questo mese_ (intero mese di calendario),
  _Ultimi 15 giorni_ — oltre al filtro avanzato per tipo, categoria e intervallo
  di date.
- **Categorie** entrate/uscite gestibili (con selettore Entrata/Uscita).
- **Statistiche**: grafici a torta per categoria e due grafici lineari
  **indipendenti** (entrate e uscite) con totale e dettaglio per giorno.
- **Backup / Restore**:
  - remoto verso il backend configurabile;
  - **locale**: salvataggio del DB come file `.json` e ricaricamento da file.

## Architettura (in breve)

- **Storage**: [sembast](https://pub.dev/packages/sembast) (NoSQL a documenti),
  file `quanto_spendo.db` nella cartella documenti dell'app.
- `lib/models/` — modelli (`Event`, `Category`, `Nature`, `Home`, `User`, filtri).
- `lib/dao/` — accesso ai dati per store.
- `lib/db/app_database.dart` — singleton DB + export/import JSON.
- `lib/screens/` e `lib/components/` — UI.
- `lib/services/logging_http_client.dart` — client HTTP che **logga tutte le
  chiamate REST** (nome log: `REST`).
- `lib/config/app_config.dart` — configurazione (endpoint backend).
- `lib/utils/` — helper (formattazione valuta, dialog di conferma).

## Configurazione endpoint backend

L'URL del backend è iniettato a compile-time via `--dart-define`, con fallback
all'endpoint di produzione (vedi `lib/config/app_config.dart`):

```bash
flutter run --dart-define=BACKEND_ENDPOINT=http://localhost:8000/quantospendo
```

In VS Code gli endpoint sono già impostati nelle configurazioni di
`.vscode/launch.json` (produzione e backend locale) tramite `toolArgs`.

## Avvio

```bash
flutter pub get
flutter run            # usa l'endpoint di default (produzione)
```

## Backup e dati

- Il database **non** viene toccato dagli aggiornamenti dell'app: i dati vivono
  nella sandbox documenti, non nel pacchetto. Disinstallare l'app, invece,
  li elimina.
- Fai sempre un backup (remoto o **locale → file .json**) prima di operazioni
  rischiose (import/restore sovrascrivono l'intero DB; viene chiesta conferma).
- Formato backup: export sembast standard (`{"sembast_export":1, ...}`). Gli
  importi interi nei vecchi backup vengono gestiti automaticamente.

## Note

- L'app è **solo dark mode** e in **italiano**.
- Su Flutter 3.44+ può comparire un warning sulla migrazione a _Built-in
  Kotlin_: è solo informativo, la build funziona; la migrazione completa è
  rimandata finché i plugin usati non la supportano.

---

Sviluppato con Flutter (stable). Per iniziare con Flutter:
[documentazione ufficiale](https://docs.flutter.dev/).
