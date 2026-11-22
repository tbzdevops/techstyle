# Tag 16 – DORA-Metriken: Lieferung messbar machen

## Einordnung im Unterricht

Tag 16 baut auf dem Stand nach Tag 15 auf: dem eigenen Projekt des Teams oder `day_15_solution`. Das Classroom-Repository des Projektauftrags (`day16`) enthält den Stand von `day_15_solution` und die Vorlage `DORA.md`. Aus der Praxis desselben Tages kommt das fertige Werkzeug `dora.py`, das aus einem Deployment-Protokoll die fünf DORA-Metriken berechnet, und die Entscheidungen zu den Streitfällen (P1) vom Nimbus-Board.

Das Projekt dauert 70 Minuten (danach Gallery Walk) und ist in vier Schritte gegliedert. Neu oder geändert:

| Datei | Schritt | Zweck |
|-------|---------|-------|
| [`.github/workflows/deploy-aws.yml`](../.github/workflows/deploy-aws.yml) | 1 | `environment: production` im Deploy-Job: GitHub zeichnet jedes Deployment auf |
| [`.github/ISSUE_TEMPLATE/incident.yml`](../.github/ISSUE_TEMPLATE/incident.yml) | 1 | Issue-Vorlage «Vorfall (Incident)» mit Label `incident` und Pflichtfeld Commit-SHA |
| [`scripts/dora.py`](../scripts/dora.py) | 2 | Werkzeug aus der Praxis, unverändert kopiert: fünf Metriken, Median, Einordnung nach der Kursskala |
| [`scripts/dora_collect.py`](../scripts/dora_collect.py) | 2 | Holt Workflow-Läufe, Commit-Vergleiche und Incident-Issues aus der GitHub REST API und schreibt das Protokoll als CSV |
| [`.github/workflows/dora.yml`](../.github/workflows/dora.yml) | 2 | Messpipeline: jeden Montag und auf Knopfdruck, nur Leserechte, Bericht in der Zusammenfassung des Laufs |
| [`DORA.md`](../DORA.md) | 1, 4 | Definitionen, Messwerte mit Stufen, Link zum Lauf, Grenzen der Daten, Massnahme für die Retro an Tag 17 |

`dora_collect.py`, `dora.yml` und die Issue-Vorlage entsprechen wörtlich den Vorlagen in der Tagesplanung `Tag16.md`.

## Ablauf im Projekt

| Zeit | Schritt | Was |
|------|---------|-----|
| 10 Min | – | Einrichten: Auftrag annehmen, Codespace, Rollen für Schritt 2 |
| 10 Min | 1 | Messbar machen: `environment: production`, Label und Issue-Vorlage `incident`, Definitionen in `DORA.md` |
| 20 Min | 2 | Messpipeline: `scripts/dora.py` übernehmen, `dora_collect.py` und `dora.yml` parallel anlegen |
| 15 Min | 3 | Liefern: jede Person eine Änderung per Pull Request, ein absichtlicher Vorfall, ein Hotfix mit `Fixes #<Nummer>` |
| 15 Min | 4 | Auswerten: «DORA-Metriken» starten, Werte, Stufen und Link in `DORA.md`, Grenzen und Massnahme |

## Voraussetzungen

- Keine Secrets: `dora.yml` braucht nur den `GITHUB_TOKEN` des Laufs mit `actions: read`, `contents: read`, `issues: read`.
- Ohne laufendes AWS-Deployment (Learner Lab aus) setzt die Gruppe die Repository-Variable `DORA_WORKFLOW` auf `ci.yml` und hält das in `DORA.md` unter **Grenzen der Daten** fest.
- Label `incident` im Repository (`gh label create incident --color B60205`). Die Issue-Vorlage setzt es nur, wenn es existiert.

## Abnahmekriterien

- [x] Schritt 1: Deploy-Job meldet die Umgebung `production`.
- [x] Schritt 1: Issue-Vorlage für Vorfälle mit Label `incident`.
- [x] Schritt 1: `DORA.md` definiert Deployment, fehlgeschlagenes Deployment und Beginn der Lead Time.
- [x] Schritt 2: `scripts/dora.py` berechnet alle fünf Metriken korrekt.
- [x] Schritt 2: `scripts/dora_collect.py` liest Workflow-Läufe und Vorfälle über die GitHub-API.
- [x] Schritt 2: `dora.yml` läuft wöchentlich und auf Knopfdruck, hat nur Leserechte, ruft `dora_collect.py` und `dora.py` auf und schreibt den Bericht in die Zusammenfassung des Laufs.
- [x] Schritt 4: `DORA.md` enthält Messwerte mit Stufen, einen Link zum Lauf, die Grenzen der Daten und eine Massnahme für die Retro.
- [ ] Mindestens vier Deployments und ein mit Hotfix geschlossenes Issue `incident` (pro Gruppe im eigenen Repository, manuell abgenommen).

Die Werte in `DORA.md` sind Beispielwerte einer Gruppe; der verlinkte Lauf ist ein Platzhalter.

## Testen

```bash
# Abnahmekriterien lokal prüfen (14 Kriterien)
CLASSROOM_DAY=16 bash .github/classroom/grade.sh

# Messpipeline lokal gegen das eigene Repository (mit der GitHub CLI angemeldet)
GITHUB_REPOSITORY=<owner>/<repo> GITHUB_TOKEN=$(gh auth token) DORA_WORKFLOW=ci.yml \
    python scripts/dora_collect.py deployments.csv
python scripts/dora.py deployments.csv --tage 28
```

## Wichtige Erkenntnisse

- **Definitionen vor Zahlen:** Erst die Festlegung, was ein Deployment, ein Fehler und der Beginn der Lead Time ist, macht die Werte vergleichbar. Drei Stellen in `dora_collect.py` setzen sie um: `status: success`, `labels: incident` mit der SHA und `first_commit_time()`.
- **Ehrliche Grenzen:** Fünf Deployments aus einer Lektion sind keine Statistik. `restored_at` ist der Zeitpunkt, an dem das Issue geschlossen wurde, nicht das Ende des Hotfix-Deployments.
- **Von der Metrik zum Hebel:** Die Massnahme nennt Metrik, Fähigkeit, konkrete Massnahme und Erfolgsmessung. Sie ist der Input für die Retro an Tag 17.
