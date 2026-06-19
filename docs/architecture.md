# Architektur

## Kontext

TechStyle ist eine klassische serverseitig gerenderte Webapplikation. Flask nimmt
HTTP-Requests entgegen, liest oder schreibt Daten in MySQL und rendert HTML ueber
Jinja2-Templates.

```text
Browser
  |
  | HTTP
  v
Flask / Gunicorn
  |
  | SQL
  v
MySQL / MariaDB
```

## Wichtige Dateien und Ordner

- `application.py`: Flask-Routen, Session-Handling und Datenbankzugriff
- `wsgi.py`: WSGI-Einstiegspunkt fuer Gunicorn oder andere WSGI-Server
- `templates/`: HTML-Templates
- `static/css/`: Stylesheets
- `static/js/`: Clientseitiges JavaScript
- `static/img/`: Produktbilder und UI-Bilder
- `ecommerce.sql`: Datenbankschema mit Beispieldaten
- `requirements.txt`: Python-Abhaengigkeiten
- `Procfile`: Startkommando fuer PaaS-/Procfile-basierte Deployments

## Konfiguration

Die Datenbankverbindung wird ueber `DATABASE_URL` gesetzt. Dadurch bleiben
Umgebungsdetails wie Host, Benutzername und Passwort ausserhalb des Git-Verlaufs.

Beispiel:

```text
mysql://techstyle:techstyle@localhost:3306/ecommerce
```

## Betriebsannahmen

- Die Datenbank ist vor dem Start erreichbar.
- Die Tabellen aus `ecommerce.sql` sind importiert.
- Session-Daten werden lokal im Dateisystem gespeichert.
- Produktbilder liegen im Repository unter `static/img/`.

## Naechste technische Verbesserungen

- Passwort-Hashing einfuehren.
- Warenkorb pro Benutzer isolieren.
- Tests fuer Registrierung, Login, Warenkorb und Checkout ergaenzen.
- Datenbankmigrationen statt manuellem SQL-Import einfuehren.
