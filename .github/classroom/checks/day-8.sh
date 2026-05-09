#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 8 — Monitoring & Observability Setup"
echo ""

check \
  "Alle vorherigen CI/CD-Checks erfüllt" \
  "[ -d '.github/workflows' ] && ls .github/workflows/*.yml &>/dev/null"

check_file_contains \
  "Logging oder Monitoring erwähnt" \
  "README.md|docs/*.md|app.py" \
  "log|monitor|metric|prometheus|grafana"

check_file_exists \
  "Health-Check oder Status-Endpoint dokumentiert" \
  "README.md|docs/*.md|app.py"

summary
