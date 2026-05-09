#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 12 — Skalierung & Performance"
echo ""

check_file_contains \
  "Skalierungs-Dokumentation vorhanden" \
  "README.md|docs/*.md|SCALING.md" \
  "scale|load|performance|benchmark|concurrent"

check_file_contains \
  "Lasttest oder Performance-Test dokumentiert" \
  "README.md|docs/*.md|tests/*.py|PERFORMANCE.md" \
  "load.test|loadtest|performance|benchmark|k6|jmeter"

check \
  "Dokumentation hat ausreichend Inhalt (mind. 100 Wörter)" \
  "[ \$(grep -h . README.md docs/*.md SCALING.md PERFORMANCE.md 2>/dev/null | wc -w) -ge 100 ]"

summary
