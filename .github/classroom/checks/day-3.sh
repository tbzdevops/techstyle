#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 3 — MVP & Dokumentation"
echo ""

check_file_exists \
  "Dokumentation oder Konzept vorhanden" \
  "docs/README.md|CONCEPT.md|MVP.md|docs/architecture.md"

check_file_exists \
  "App-Code existiert" \
  "app.py|main.py|src/app.py"

check_file_contains \
  "App hat Funktionalität (Imports/Funktionen)" \
  "app.py" \
  "def|import|class"

summary
