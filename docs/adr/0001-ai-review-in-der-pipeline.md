# ADR 0001: AI-Review in der CI/CD-Pipeline

## Status
Akzeptiert

## Kontext
Pull Requests auf TechStyle warten oft Stunden auf ein menschliches Review. Einfache Fehler
(fehlende Fehlerbehandlung, hartkodierte Secrets, falsche Randfälle) rutschen trotzdem durch.
Das Team will eine schnelle erste Einschätzung pro PR, ohne die menschliche Freigabe
aufzugeben und ohne zusätzliche API-Keys zu verwalten.

## Entscheidung
Wir ergänzen die Pipeline um `.github/workflows/ai-review.yml`:

- Trigger: `pull_request` mit geänderten `*.py`-Dateien
- Modell: `openai/gpt-4o-mini` über GitHub Models, authentifiziert mit dem `GITHUB_TOKEN`
  (`permissions: models: read`), kein externer API-Key
- Eingabe: nur der Python-Diff, max. 6000 Zeichen, zwischen `<diff>`-Begrenzern und im
  System-Prompt als Daten gekennzeichnet
- Ausgabe: ausschliesslich ein PR-Kommentar mit AI-Hinweis — **kein** Merge-Gate, kein
  Required Status Check
- Fallback-Kommentar, wenn die API nicht antwortet

## Konsequenzen
- **Nutzen:** Erste Rückmeldung innert Minuten; Reviewer sehen offensichtliche Punkte vorab.
- **Kosten:** GitHub Models ist im Rahmen der Rate-Limits kostenlos; bei vielen PRs pro Tag
  werden Limits erreicht, der Fallback greift dann.
- **Security:** Der PR-Autor kontrolliert einen Teil des Prompts (indirekte Prompt Injection).
  Begrenzer und gehärteter System-Prompt senken das Risiko, beseitigen es nicht — deshalb hat
  der Bot keine Entscheidungsbefugnis. PR-Inhalte gelangen nur über `env:`/Dateien in Skripte
  (keine Script Injection). Der Diff verlässt GitHub nicht, wird aber von einem LLM verarbeitet:
  Secrets gehören ohnehin nicht in den Code.
- **Wartung:** Modellnamen und Endpunkte ändern sich; der Workflow muss dann angepasst werden.
  Die Qualität der Kommentare ist nicht deterministisch und wird im Team periodisch geprüft.
