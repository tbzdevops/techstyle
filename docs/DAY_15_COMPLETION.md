# Tag 15 – DevSecOps: Security-Pipeline für TechStyle

## Einordnung im Unterricht

Tag 15 baut auf dem Stand nach Tag 14 auf: dem eigenen Projekt des Teams oder `day_14_solution`. Das Classroom-Repository des Projektauftrags (`day15`) enthält den Stand von `day_14_solution`. Die Praxis desselben Tages (Snyk und OWASP ZAP lokal an DSVPWA) ist Voraussetzung für das Verständnis, nicht für den Code.

Die Gruppen (3–4 Personen) teilen sich die Arbeit in zwei Rollen und bereiten gemeinsam einen Kunden-Pitch vor. Neu sind:

| Datei | Rolle | Zweck |
|-------|-------|-------|
| [`.github/workflows/security.yml`](../.github/workflows/security.yml) | 1 – Gate | SCA (`snyk test`) und SAST (`snyk code test`) bei jedem Push auf `main` und jedem Pull-Request, Abbruch nur bei High/Critical, SARIF-Upload in den Security-Tab |
| [`.github/workflows/container-scan.yml`](../.github/workflows/container-scan.yml) | 2 – Container | Image bauen und mit `snyk container test` scannen, vorerst nur warnend (`continue-on-error: true`) |
| [`Dockerfile`](../Dockerfile) | 2 – Container | Base-Image von `python:3.11-slim` auf `python:3.13-slim` angehoben. Welches Image Snyk vorschlägt, steht im Log von `snyk container test` und kann sich mit neuen Releases ändern |
| [`PITCH.md`](../PITCH.md) | Alle | Pitch für den Shop-Betreiber: Risiko, Lösung, Beweis, Nutzen und vorbereitete Kundenfragen |

Die beiden Workflows entsprechen wörtlich den Vorlagen in der Tagesplanung `Tag15.md`.

## Voraussetzungen

- Repository-Secret `SNYK_TOKEN` (Snyk → Account Settings → Auth Token)
- In der Snyk-Organisation ist **Snyk Code** aktiviert, sonst scheitert `snyk code test`
- Für den SARIF-Upload in **privaten** Repositories braucht es «GitHub Code Security». Ohne Lizenz die SARIF-Dateien mit `actions/upload-artifact@v4` ablegen

## Gate-Beweis

1. Branch anlegen, in `requirements.txt` die Zeile `PyYAML==5.3` ergänzen, Pull-Request öffnen.
2. Der Workflow **Security** wird rot: `snyk test` meldet CVE-2020-14343 (Critical, behoben in 5.4).
3. Den Pull-Request **nicht** mergen. Link zum roten Lauf in `PITCH.md` unter «Der Beweis» eintragen.

`PyYAML==5.3` installiert sich auf Python 3.11 problemlos aus dem Quellpaket. Der Lauf scheitert also am Gate und nicht schon bei `pip install`.

## Abnahmekriterien

- [x] `.github/workflows/security.yml` führt `snyk test` und `snyk code test` bei jedem Push und Pull-Request aus.
- [x] Der Build scheitert nur bei High- und Critical-Findings (`--severity-threshold=high`).
- [x] Die Findings werden als SARIF in den Security-Tab hochgeladen.
- [x] Das Container-Image wird mit `snyk container test` gescannt, das Base-Image ist nach der Empfehlung aktualisiert.
- [ ] Ein Pull-Request mit verwundbarer Abhängigkeit wurde vom Gate gestoppt (pro Gruppe im eigenen Repository, braucht `SNYK_TOKEN`).
- [x] `PITCH.md` enthält den Pitch mit Risiko, Lösung, Beweis und Nutzen.

## Testen

```bash
# Workflows lokal auf gültiges YAML prüfen
python -c "import yaml; [yaml.safe_load(open(f)) for f in ['.github/workflows/security.yml', '.github/workflows/container-scan.yml']]"

# Shop mit neuem Base-Image starten (wie an Tag 13)
cp .env.container.example .env.container
docker compose --env-file .env.container up --build -d --wait
curl -fsS http://localhost:5001/healthz

# Scans lokal (mit Snyk-Login)
pip install -r requirements.txt && snyk test --severity-threshold=high
snyk code test --severity-threshold=high
docker build -t techstyle:ci . && snyk container test techstyle:ci --file=Dockerfile --severity-threshold=high
```

## Wichtige Erkenntnisse

- **Erst warnen, dann blockieren:** Der SCA/SAST-Gate blockiert sofort, der Container-Scan zunächst nicht. TechStyle enthält absichtlich Schwachstellen (z.B. Klartext-Secrets in `app.py`). Meldet `snyk code test` diese als High, ist `main` schon vor dem Gate-Beweis rot. Dann zuerst triagieren (beheben oder mit Ablaufdatum akzeptieren), damit das Gate aussagekräftig wird.
- **Erreichbarkeit zählt:** Wie in der Praxis an DSVPWA ist nicht jedes Finding ausnutzbar. Die Triage entscheidet, nicht die Anzahl.
- **Das Gate muss sichtbar scheitern:** Erst der rote Pull-Request beweist dem Kunden, dass die Pipeline schützt.
