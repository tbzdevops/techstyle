# Contributing

## Arbeitsweise

1. Vor der Arbeit den aktuellen Stand holen.
2. Eine eigene Feature- oder Fix-Branch erstellen.
3. Kleine, fachlich zusammenhaengende Commits erstellen.
4. Aenderungen lokal pruefen.
5. Pull Request erstellen und Review abwarten.

## Branch-Namen

Branch-Namen beschreiben die Aufgabe kurz und eindeutig.

```text
feature/cart-per-user
fix/login-validation
docs/setup-guide
chore/update-dependencies
```

## Commit-Messages

Commits folgen einem einfachen Conventional-Commits-Stil:

```text
type: kurze beschreibung
```

Erlaubte Typen:

- `feat`: neue Funktion
- `fix`: Fehlerkorrektur
- `docs`: Dokumentation
- `chore`: Wartung, Konfiguration oder Repository-Pflege
- `refactor`: interne Codeverbesserung ohne neues Verhalten
- `test`: Tests

Beispiele:

```text
docs: document local setup
chore: externalize database configuration
fix: validate empty cart before checkout
```

## Pull Requests

Ein Pull Request soll folgende Punkte enthalten:

- kurze Beschreibung der Aenderung
- betroffene Dateien oder Bereiche
- manuelle oder automatische Pruefung
- offene Risiken oder bekannte Einschraenkungen

## Lokale Pruefung

Vor einem Pull Request mindestens ausfuehren:

```bash
py -m py_compile application.py wsgi.py
```

Wenn eine lokale Datenbank vorhanden ist:

```bash
flask run
```

Danach im Browser Login, Produktliste, Warenkorb und Checkout kurz manuell pruefen.

## Secrets

Keine Passwoerter, Tokens, privaten Keys oder produktiven Hostnamen committen.
Lokale Werte gehoeren in `.env`; eine neutrale Vorlage liegt in `.env.example`.

Falls versehentlich ein Secret committed wurde:

1. Secret sofort rotieren.
2. Team informieren.
3. Git-Historie bereinigen, bevor die Branch geteilt wird.
