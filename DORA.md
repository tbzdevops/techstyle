# DORA-Messung TechStyle

## Definitionen

### Deployment

Ein Deployment ist ein erfolgreicher Lauf von «Tag 14 - Deployment auf AWS» (deploy-aws.yml) auf dem Branch main, der das Image auf die EC2-Instanz in Produktion ausrollt. Staging und Läufe auf anderen Branches zählen nicht. Weil unser Learner Lab heute nicht lief, haben wir DORA_WORKFLOW ersatzweise auf ci.yml gesetzt.

### Fehlgeschlagenes Deployment

Ein Deployment ist fehlgeschlagen, wenn es sofort einen Eingriff braucht, also einen Rollback oder Hotfix. Wir erfassen das als Issue mit dem Label incident, das die Commit-SHA des Deployments nennt. Auch ein automatischer Rollback zählt.

### Beginn der Lead Time

Die Lead Time beginnt beim ältesten Commit, der mit dem Deployment neu in Produktion kommt, und endet, wenn der Deployment-Lauf fertig ist. dora_collect.py vereinfacht: Es misst pro Deployment ab dem ältesten neuen Commit, nicht pro Commit.

## Messwerte

Lauf: https://github.com/tbzdevops/techstyle-day16-team1/actions/runs/123456789

| Metrik | Wert | Stufe |
|--------|------|-------|
| Deployment Frequency | 1.8 pro Tag | Elite |
| Lead Time for Changes | 0.4 h | Elite |
| Change Failure Rate | 20 % | Mittel |
| Failed Deployment Recovery Time | 0.3 h | Elite |
| Rework Rate | 20 % | – |

## Grenzen der Daten

Wir haben nur fünf Deployments aus einer einzigen Lektion, das ist statistisch kaum belastbar. Wir messen ersatzweise die CI-Pipeline und nicht das echte AWS-Deployment. Die Recovery Time endet beim Schliessen des Issues und nicht beim Ende des Hotfix-Deployments. Vorfälle ohne Issue fehlen ganz.

## Massnahme für die Retro (Tag 17)

| Feld | Antwort |
|------|---------|
| Metrik | Change Failure Rate |
| Fähigkeit dahinter | Testautomatisierung und kleine Batches |
| Massnahme | Einen Test für die Warenkorb-Summe ergänzen, bevor wir wieder deployen |
| Woran wir den Erfolg messen | Change Failure Rate in vier Wochen unter 10 Prozent |
