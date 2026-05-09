#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 1 — AWS Setup & App Vorbereitung"
echo ""

check_file_exists \
  "AWS Credentials-Datei oder Konfiguration vorhanden" \
  ".env"

check_file_exists \
  "README.md existiert" \
  "README.md"

check_file_contains \
  "App-Dokumentation im README" \
  "README.md" \
  "app|techstyle|setup|install"

summary
