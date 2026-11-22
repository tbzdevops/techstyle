#!/bin/bash
# PROJEKT Tag 16 — DORA-Metriken für die TechStyle-Pipeline.
# Ausgangsstand ist day_15_solution. Geprüft werden die Messbarkeit
# (environment im Deploy-Job, Issue-Vorlage für Vorfälle), die Messpipeline
# (scripts/dora.py, scripts/dora_collect.py, .github/workflows/dora.yml) und
# die Auswertung in DORA.md. Der Rechenkern wird mit einem eigenen Protokoll
# nachgerechnet, nicht nur gesucht. Die Workflow-Kriterien prüfen nur dora.yml,
# weil ai-prompt-eval.yml im Ausgangsstand schon GITHUB_STEP_SUMMARY nutzt.
# DORA.md liegt als Vorlage im Repo: Gezählt wird nur Text ausserhalb der
# HTML-Kommentare. classroom.yml zählt nie als Lösung.
source .github/classroom/grade.sh

solution_for_id() {
  case "$1" in
    a1-environment) echo "Ergänze im Deploy-Job von deploy-aws.yml die Zeile 'environment: production' (auf gleicher Höhe wie runs-on)" ;;
    a1-incident) echo "Lege .github/ISSUE_TEMPLATE/incident.yml an, mit 'labels: [\"incident\"]' und einem Feld für die Commit-SHA (Vorlage in Tag16.md)" ;;
    a1-definitions) echo "Ersetze in DORA.md unter '### Deployment', '### Fehlgeschlagenes Deployment' und '### Beginn der Lead Time' den Kommentar durch eure Definition (je mindestens ein bis zwei Sätze)" ;;
    a2-core) echo "Kopiere euren Rechenkern aus der Praxis nach scripts/dora.py; alle Funktionen müssen die Tests aus der Praxis bestehen" ;;
    a2-collect) echo "Lege scripts/dora_collect.py nach der Vorlage in Tag16.md an: Workflow-Läufe über /actions/workflows/<datei>/runs, Vorfälle über Issues mit Label incident" ;;
    a2-trigger) echo "Gib .github/workflows/dora.yml die Trigger 'schedule:' (mit cron) und 'workflow_dispatch:'" ;;
    a2-permissions) echo "Setze in dora.yml 'permissions:' mit 'actions: read', 'contents: read' und 'issues: read', ohne write" ;;
    a2-pipeline) echo "Rufe in dora.yml zuerst 'python scripts/dora_collect.py deployments.csv' und dann 'python scripts/dora.py deployments.csv' auf" ;;
    a2-summary) echo "Hänge in dora.yml die Ausgabe von dora.py an \"\$GITHUB_STEP_SUMMARY\" an (>> \"\$GITHUB_STEP_SUMMARY\")" ;;
    a4-values) echo "Trage in DORA.md unter '## Messwerte' für alle fünf Metriken den Wert aus der Zusammenfassung des Laufs ein" ;;
    a4-levels) echo "Trage in DORA.md unter '## Messwerte' in der Spalte Stufe Elite, Hoch, Mittel oder Niedrig ein" ;;
    a4-run) echo "Trage in DORA.md hinter 'Lauf:' den Link zu einem Lauf von «DORA-Metriken» ein (…/actions/runs/<nr>)" ;;
    a4-limits) echo "Beschreibe in DORA.md unter '## Grenzen der Daten', wie belastbar die Zahlen sind (mindestens drei Sätze)" ;;
    a4-action) echo "Fülle in DORA.md unter '## Massnahme für die Retro (Tag 17)' alle vier Zeilen: Metrik, Fähigkeit, Massnahme, Erfolgsmessung" ;;
    *) echo "Überprüfe die Aufgabenstellung im README" ;;
  esac
}

DORA_MD=DORA.md
CORE=scripts/dora.py
COLLECT=scripts/dora_collect.py
WF=.github/workflows/dora.yml

# Workflows ohne die Autograding-Pipeline.
workflows() {
  local f
  for f in .github/workflows/*.yml .github/workflows/*.yaml; do
    [ -f "$f" ] || continue
    case "$f" in */classroom.yml|*/classroom.yaml) continue ;; esac
    echo "$f"
  done
}

# Ein Job irgendeines Workflows deployt in die Umgebung production.
environment_ok() {
  local f
  for f in $(workflows); do
    python3 - "$f" <<'PY' && return 0
import re, sys
text = open(sys.argv[1], encoding="utf-8").read()
one_line = re.search(r"^\s+environment:\s*['\"]?production\b", text, re.M)
block = re.search(r"^(\s+)environment:\s*\n\1\s+name:\s*['\"]?production\b", text, re.M)
sys.exit(0 if one_line or block else 1)
PY
  done
  return 1
}

incident_template_ok() {
  local f
  for f in .github/ISSUE_TEMPLATE/*.yml .github/ISSUE_TEMPLATE/*.yaml .github/ISSUE_TEMPLATE/*.md; do
    [ -f "$f" ] || continue
    grep -qiE '^labels:.*incident' "$f" && return 0
    # Liste über mehrere Zeilen: labels:\n  - incident
    grep -A3 -iE '^labels:[[:space:]]*$' "$f" | grep -qiE '^[[:space:]]*-[[:space:]]*["'\'']?incident' && return 0
  done
  return 1
}

# Rechnet scripts/dora.py mit einem eigenen Protokoll nach.
core_ok() {
  [ -f "$CORE" ] || return 1
  python3 - "$CORE" <<'PY'
import importlib.util, os, sys, tempfile
spec = importlib.util.spec_from_file_location("dora_core", sys.argv[1])
dora = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dora)
csv_text = """deployed_at,committed_at,failed,restored_at,rework
2026-11-09T08:00:00Z,2026-11-09T06:00:00Z,nein,,nein
2026-11-09T12:00:00Z,2026-11-09T11:00:00Z,ja,2026-11-09T16:00:00Z,nein
2026-11-10T09:00:00Z,2026-11-10T05:00:00Z,nein,,ja
2026-11-12T15:00:00Z,2026-11-11T15:00:00Z,ja,2026-11-12T15:30:00Z,nein
"""
fd, path = tempfile.mkstemp(suffix=".csv")
with os.fdopen(fd, "w", encoding="utf-8") as handle:
    handle.write(csv_text)
try:
    deps = dora.load(path)
finally:
    os.remove(path)
close = lambda a, b: a is not None and abs(a - b) < 1e-6
ok = (
    close(dora.deployment_frequency(deps, 4), 1.0)
    and close(dora.lead_time_hours(deps), 3.0)          # 2, 1, 4, 24 -> 3
    and close(dora.change_failure_rate(deps), 0.5)
    and close(dora.recovery_time_hours(deps), 2.25)     # 4 und 0.5 -> 2.25
    and close(dora.rework_rate(deps), 0.25)
    and dora.classify("frequency", 1.0) == "Elite"
    and dora.classify("lead_time", 30) == "Hoch"
    and dora.classify("change_failure_rate", 0.5) == "Niedrig"
    and dora.classify("recovery", 2.25) == "Hoch"
)
sys.exit(0 if ok else 1)
PY
}

# Wertet DORA.md aus. Argument: Name des Kriteriums. Exit 0 = erfüllt.
doc_ok() {
  python3 - "$1" "$DORA_MD" <<'PY'
import re, sys

criterion, path = sys.argv[1], sys.argv[2]
try:
    text = open(path, encoding="utf-8").read()
except OSError:
    sys.exit(1)
text = re.sub(r"<!--.*?-->", "", text, flags=re.S)

def section(title_re, level):
    lines = text.splitlines()
    for i, line in enumerate(lines):
        m = re.match(r"^(#{1,6})\s+(.*)$", line)
        if m and len(m.group(1)) == level and re.search(title_re, m.group(2).strip(), re.I):
            out = []
            for nxt in lines[i + 1:]:
                n = re.match(r"^(#{1,6})\s", nxt)
                if n and len(n.group(1)) <= level:
                    break
                out.append(nxt)
            return "\n".join(out)
    return None

def words(block):
    return len(re.findall(r"[A-Za-zÄÖÜäöü0-9]{2,}", block or ""))

def table(block):
    rows = []
    for line in (block or "").splitlines():
        line = line.strip()
        if line.startswith("|"):
            cells = [c.strip() for c in line.strip("|").split("|")]
            if all(re.fullmatch(r":?-{2,}:?", c) for c in cells if c):
                continue
            rows.append(cells)
    return rows[1:]

METRICS = ["Deployment Frequency", "Lead Time", "Change Failure Rate", "Recovery Time", "Rework Rate"]

def metric_rows():
    rows = table(section(r"^Messwerte$", 2))
    found = {}
    for r in rows:
        for m in METRICS:
            if len(r) >= 2 and m.lower() in r[0].lower():
                found[m] = r
    return found

if criterion == "a1-definitions":
    titles = [r"^Deployment$", r"^Fehlgeschlagenes Deployment$", r"^Beginn der Lead Time$"]
    ok = all(words(section(t, 3)) >= 8 for t in titles)
elif criterion == "a4-values":
    rows = metric_rows()
    # Ohne Vorfall bleibt die Recovery Time leer («–»), darum reichen vier Zahlen.
    ok = len(rows) == 5 and sum(1 for r in rows.values() if re.search(r"\d", r[1])) >= 4
elif criterion == "a4-levels":
    rows = metric_rows()
    ok = sum(1 for r in rows.values() if len(r) >= 3 and re.search(r"\b(Elite|Hoch|Mittel|Niedrig)\b", r[2], re.I)) >= 3
elif criterion == "a4-run":
    ok = re.search(r"https://github\.com/[^/\s]+/[^/\s]+/actions/runs/\d+", section(r"^Messwerte$", 2) or "") is not None
elif criterion == "a4-limits":
    ok = words(section(r"^Grenzen der Daten$", 2)) >= 25
elif criterion == "a4-action":
    rows = table(section(r"^Massnahme", 2))
    ok = len(rows) >= 4 and all(len(r) >= 2 and words(r[1]) >= 2 for r in rows[:4])
else:
    ok = False
sys.exit(0 if ok else 1)
PY
}

echo "🔍 Prüfe Abnahmekriterien für Tag 16 Projekt — DORA-Metriken für TechStyle"
echo ""

echo "── Schritt 1: Messbar machen ──"

check "a1-environment" \
  "Schritt 1: Deploy-Job meldet die Umgebung production" \
  "environment_ok"

check "a1-incident" \
  "Schritt 1: Issue-Vorlage für Vorfälle mit Label incident" \
  "incident_template_ok"

check "a1-definitions" \
  "Schritt 1: DORA.md definiert Deployment, fehlgeschlagenes Deployment und Beginn der Lead Time" \
  "doc_ok a1-definitions"

echo ""
echo "── Schritt 2: Messpipeline ──"

check "a2-core" \
  "Schritt 2: scripts/dora.py berechnet alle fünf Metriken korrekt" \
  "core_ok"

check "a2-collect" \
  "Schritt 2: scripts/dora_collect.py liest Workflow-Läufe und Vorfälle über die GitHub-API" \
  "[ -f $COLLECT ] && grep -qE 'actions/(workflows|runs)' $COLLECT && grep -qE 'issues' $COLLECT && grep -qE 'incident' $COLLECT"

check "a2-trigger" \
  "Schritt 2: dora.yml läuft wöchentlich und auf Knopfdruck" \
  "[ -f $WF ] && grep -qE '^[[:space:]]+schedule:' $WF && grep -qE 'cron:' $WF && grep -qE '^[[:space:]]+workflow_dispatch:' $WF"

check "a2-permissions" \
  "Schritt 2: dora.yml hat nur Leserechte" \
  "[ -f $WF ] && grep -qE '^[[:space:]]*permissions:' $WF && grep -qE 'actions:[[:space:]]*read' $WF && ! grep -qiE 'write' $WF"

check "a2-pipeline" \
  "Schritt 2: dora.yml ruft dora_collect.py und dora.py auf" \
  "[ -f $WF ] && grep -qE 'dora_collect\.py' $WF && grep -qE 'scripts/dora\.py' $WF"

check "a2-summary" \
  "Schritt 2: dora.yml schreibt den Bericht in die Zusammenfassung des Laufs" \
  "[ -f $WF ] && grep -qE 'GITHUB_STEP_SUMMARY' $WF"

echo ""
echo "── Schritt 4: Auswerten ──"

check "a4-values" \
  "Schritt 4: DORA.md enthält Messwerte für alle fünf Metriken" \
  "doc_ok a4-values"

check "a4-levels" \
  "Schritt 4: DORA.md ordnet die Werte nach Stufen ein" \
  "doc_ok a4-levels"

check "a4-run" \
  "Schritt 4: DORA.md verlinkt einen Lauf von «DORA-Metriken»" \
  "doc_ok a4-run"

check "a4-limits" \
  "Schritt 4: DORA.md beschreibt die Grenzen der Daten" \
  "doc_ok a4-limits"

check "a4-action" \
  "Schritt 4: DORA.md leitet eine Massnahme für die Retro an Tag 17 ab" \
  "doc_ok a4-action"

summary 16
