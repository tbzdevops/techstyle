# Pitch: Eine Security-Pipeline für TechStyle

> 2–3 Minuten für den Shop-Betreiber, ohne Fachjargon. Danach Fragen des Kunden.

## 1. Das Risiko

Heute kann jede Änderung am Shop ungeprüft live gehen. Unsere Scans zeigen zwei konkrete Beispiele:

- **Zugangsdaten im Quellcode:** In `app.py` stehen das Datenbank-Passwort, das Admin-Passwort und ein Zahlungs-API-Schlüssel im Klartext. Wer den Code sieht, zum Beispiel ein ehemaliger Mitarbeiter oder ein gestohlener Laptop, kann damit Zahlungen auslösen oder die Datenbank öffnen. Genau so sind beim Konkurrenten die Kundendaten abgeflossen.
- **Datenbankabfragen aus zusammengesetztem Text:** Mehrere Abfragen im Warenkorb und bei den Bestellungen werden mit `+` zusammengebaut. Gelangt eine Benutzereingabe hinein, kann ein Angreifer die Abfrage verändern und fremde Bestellungen lesen.
- **Veraltetes Fundament:** Das Container-Image basierte auf `python:3.11-slim`. Snyk Container meldet darin bekannte Lücken im Betriebssystem, die wir selbst nie geschrieben haben, aber mit ausliefern.

## 2. Die Lösung

Drei automatische Prüfungen laufen bei **jeder** Änderung, bevor sie live geht:

| Was wird geprüft? | Werkzeug | Wann? |
|-------------------|----------|-------|
| Fremde Bausteine (Bibliotheken) auf bekannte Lücken | Snyk Open Source (SCA) | bei jedem Push und Pull-Request |
| Unser eigener Code auf unsichere Muster | Snyk Code (SAST) | bei jedem Push und Pull-Request |
| Das fertige Container-Image inklusive Betriebssystem | Snyk Container | bei jedem Push und Pull-Request |

Die Pipeline stoppt nur bei **schweren** Funden (High und Critical). Kleinere Funde erscheinen im Security-Tab von GitHub und werden geplant behoben. Der Container-Scan meldet vorerst nur und blockiert erst, wenn die bestehenden Funde aufgeräumt sind.

## 3. Der Beweis

Wir haben absichtlich eine verwundbare Bibliothek eingebaut (`PyYAML==5.3`, bekannte kritische Lücke CVE-2020-14343) und einen Pull-Request geöffnet. Die Pipeline wurde rot, der Pull-Request konnte nicht unbemerkt in den Shop gelangen.

- Roter Lauf: _Link zum Pull-Request bzw. Actions-Lauf hier eintragen, z.B. `https://github.com/<org>/<repo>/pull/<nr>`_

Beim Base-Image haben wir auf `python:3.13-slim` gewechselt, eines der Images, die Snyk im Log als Ersatz vorschlägt. Nach dem Wechsel läuft der Shop unverändert (`docker compose up --build`).

- Container-Findings vorher (`python:3.11-slim`): _Anzahl aus dem Log eintragen_
- Container-Findings nachher (`python:3.13-slim`): _Anzahl aus dem Log eintragen_

## 4. Der Nutzen

- **Weniger Risiko:** Bekannte Lücken kommen gar nicht erst in den Shop.
- **Früher und günstiger:** Ein Fehler, den die Pipeline nach fünf Minuten meldet, kostet einen Bruchteil eines Fehlers, den ein Angreifer in Produktion findet.
- **Vertrauen der Kunden:** Wir können jederzeit zeigen, welche Prüfungen gelaufen sind, auch für Audits und Zahlungsanbieter.
- **Kein Bremsklotz:** Die Prüfungen laufen automatisch parallel. Entwickler warten nur, wenn es wirklich brennt.

## Vorbereitete Antworten auf Kundenfragen

| Frage | Antwort |
|-------|---------|
| Warum behebt ihr nicht einfach alle Findings? | Nicht jedes Finding ist ausnutzbar. Wir prüfen jedes: beheben, mit Ablaufdatum akzeptieren oder als Fehlalarm begründen. So bleibt die Arbeit dort, wo das Risiko ist. |
| Bremst das meine Entwickler aus? Was kostet das? | Die Scans dauern wenige Minuten und laufen parallel zu den Tests. Snyk ist für kleine Teams kostenlos, der Aufwand ist die Einrichtung von heute und die Triage neuer Funde. |
| Findet das Tool wirklich alle Lücken? | Nein. Die Scans finden bekannte Lücken und typische Fehler. Logikfehler oder Lücken hinter dem Login braucht weiterhin dynamische Tests und gelegentlich einen Pentest. |
| Warum reicht nicht ein Penetrationstest pro Jahr? | Wir ändern den Shop mehrmals pro Woche. Ein Pentest ist eine Momentaufnahme, die Pipeline prüft jede einzelne Änderung. Beides ergänzt sich. |
| Was passiert, wenn der Build rot ist, wir aber dringend ein Update brauchen? | Gibt es keinen Fix, wird das Finding begründet und mit Ablaufdatum akzeptiert (`snyk ignore --expiry=…`). Das ist dokumentiert und wird später neu geprüft, statt das Gate abzuschalten. |
