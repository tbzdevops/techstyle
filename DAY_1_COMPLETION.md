# Tag 01 – Projekt-Abschluss (TechStyle)

Kickoff der TechStyle-Transformation: Die Flask-Anwendung wird lokal lauffähig gemacht, die
Projektdokumentation gelesen und das erste Issue auf dem Kanban-Board erstellt.

## Was in diesem Tag erreicht wird

| Projekt-Aufgabe | Ergebnis |
|-----------------|----------|
| **1. TechStyle lokal starten** | Die Flask + SQLite App läuft auf `http://localhost:5000`. |
| **2. Kickoff-Doku lesen** | `README.md` und Branching-Strategie verstanden (Ziele, Rollen, Aufbau). |
| **3. Erstes Issue erstellen** | Erstes Issue im GitHub-Repo angelegt und auf das Kanban-Board gehängt. |

> Auf diesem Branch (`day_1_solution`) liegt die vollständige, lauffähige Ausgangs-Codebasis. Es
> sind für Tag 01 **keine Code-Änderungen** nötig – das Ziel ist der lauffähige Startzustand, auf
> dem alle weiteren Tage aufbauen.

## Lokal starten & verifizieren

Mit Skript:
```bash
./run_dev.sh
```

Oder manuell:
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python seed_data.py
python app.py
```

Anschliessend <http://localhost:5000> öffnen.

**Verifikation:**
- [x] Startseite lädt (HTTP 200) und zeigt die seedeten Produkte an.
- [x] Datenbank `techstyle.db` wurde durch `seed_data.py` befüllt.
- [x] Keine Tracebacks in der Konsole beim Start.

## Erfüllte Abnahmekriterien (Tag 01)

- [x] **App läuft lokal** – TechStyle-Startseite auf `localhost:5000`.
- [x] **Board mit Issues** – erstes Issue im Repo angelegt und mit dem Kanban-Board verknüpft.
- [x] **AWS Login funktioniert** – im AWS Academy Learner Lab nachgewiesen (siehe Praxis-Auftrag 1).

## Bezug zu den nächsten Tagen

- **Tag 02:** Auf dieser Codebasis wird die Branching-Strategie eingeführt und die Versionierung
  aufgesetzt.
- **Tag 04:** Genau dieser Code erhält die erste CI-Pipeline (`.github/workflows/ci.yml`).
