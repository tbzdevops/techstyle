# Releases

## Versionierung

TechStyle verwendet Semantic Versioning:

```text
MAJOR.MINOR.PATCH
```

- `MAJOR`: inkompatible Aenderungen
- `MINOR`: neue rueckwaertskompatible Funktionen
- `PATCH`: Fehlerkorrekturen, Dokumentation oder kleine Wartung

## Tagging

Releases werden mit Git-Tags markiert.

```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

## Release-Checkliste

- Arbeitsstand ist committed.
- README und Betriebsdokumentation stimmen mit dem Stand ueberein.
- Keine lokalen Secrets oder generierten Dateien sind im Commit enthalten.
- Anwendung wurde mindestens syntaktisch geprueft.
- Offene Einschraenkungen sind dokumentiert.

## Aktueller Musterloesungsstand

`v1.0.0` steht fuer die erste saubere Uebernahme der bestehenden On-Premises-
Codebasis in ein Git-Repository.

Enthalten:

- Flask-Anwendung mit Templates und statischen Assets
- SQL-Schema und Beispieldaten
- externe Datenbankkonfiguration ueber `DATABASE_URL`
- `.gitignore` und `.env.example`
- README, Architekturhinweise, Contributing- und Release-Dokumentation

Nicht enthalten:

- automatisierte Tests
- Passwort-Hashing
- produktionsreife Session- und Warenkorb-Isolation
