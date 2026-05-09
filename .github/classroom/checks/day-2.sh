#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 2 — Git Workflows & Branches"
echo ""

check_file_exists \
  ".gitignore existiert" \
  ".gitignore"

check_file_contains \
  ".gitignore hat Python-Einträge" \
  ".gitignore" \
  "__pycache__|\.pyc|\.venv|\.env"

check_file_exists \
  "VERSION-Datei oder Setup existiert" \
  "setup.py|setup.cfg|pyproject.toml"

summary
