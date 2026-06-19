# TechStyle

TechStyle ist eine Flask-basierte Beispielapplikation fuer einen kleinen Online-Shop.
Diese Branch dokumentiert den Stand, der aus dem bisherigen On-Premises-Betrieb in ein
Git-Repository ueberfuehrt wurde.

## Zweck dieser Branch

Die Branch dient als Musterloesung fuer den Auftrag "Codebasis ins Repository bringen".
Sie zeigt, wie bestehender Anwendungscode so vorbereitet wird, dass er im Team
nachvollziehbar versioniert, lokal gestartet und spaeter weiterentwickelt werden kann.

## Technischer Ueberblick

- Backend: Python, Flask, Flask-Session
- Templates: Jinja2
- Frontend: Bootstrap, jQuery, eigenes JavaScript und CSS
- Datenbank: MySQL, Zugriff ueber `cs50.SQL`
- Startpunkt: `wsgi.py`
- Applikationslogik: `application.py`
- Datenbankschema und Beispieldaten: `ecommerce.sql`

Weitere Details stehen in [docs/architecture.md](docs/architecture.md).

## Voraussetzungen

- Python 3.11 oder neuer
- MySQL oder MariaDB
- Git
- Optional: virtualenv oder `.venv`

## Lokale Installation

```bash
py -m venv .venv
.venv\Scripts\activate
py -m pip install --upgrade pip
py -m pip install -r requirements.txt
```

Unter macOS oder Linux:

```bash
python3 -m venv .venv
source .venv/bin/activate
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt
```

## Konfiguration

Die Anwendung liest die Datenbankverbindung aus `DATABASE_URL`.
Echte Zugangsdaten gehoeren nicht ins Repository.

```bash
copy .env.example .env
```

Beispiel:

```text
DATABASE_URL=mysql://techstyle:techstyle@localhost:3306/ecommerce
FLASK_APP=application.py
FLASK_ENV=development
```

Wenn keine Umgebungsvariable gesetzt ist, verwendet die App die lokale
Default-Verbindung aus `.env.example`.

## Datenbank vorbereiten

1. Datenbank und Benutzer lokal erstellen.
2. Schema und Beispieldaten importieren.

```bash
mysql -u techstyle -p -e "CREATE DATABASE IF NOT EXISTS ecommerce;"
mysql -u techstyle -p ecommerce < ecommerce.sql
```

## Anwendung starten

```bash
set DATABASE_URL=mysql://techstyle:techstyle@localhost:3306/ecommerce
set FLASK_APP=application.py
flask run
```

Alternativ:

```bash
py wsgi.py
```

Die Anwendung ist danach standardmaessig unter `http://127.0.0.1:5000`
erreichbar.

## Repository-Hygiene

- `.env`, virtuelle Umgebungen, Python-Caches und lokale Session-Dateien sind per
  `.gitignore` ausgeschlossen.
- Konfiguration wird ueber Umgebungsvariablen gesetzt.
- Commit-Messages folgen dem Stil aus [CONTRIBUTING.md](CONTRIBUTING.md).
- Releases werden semantisch versioniert, siehe [RELEASES.md](RELEASES.md).

## Bekannte Einschraenkungen

- Passwoerter werden im aktuellen Legacy-Code noch im Klartext gespeichert.
- Der Warenkorb ist global in der Datenbank abgelegt und noch nicht sauber pro
  Benutzer getrennt.
- Es gibt noch keine automatisierten Tests.

Diese Punkte sind bewusst dokumentiert, damit die ueberfuehrte Codebasis ehrlich
bewertet und in spaeteren Auftraegen gezielt verbessert werden kann.
