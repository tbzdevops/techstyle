#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 5 — Artifacts & Package Management"
echo ""

check_file_contains \
  "CI Workflow hat Upload-Schritt (upload-artifact oder GitHub Packages)" \
  ".github/workflows/ci.yml" \
  "upload-artifact|github.packages|publish|npm|pip"

check_file_exists \
  "requirements.txt oder setup.py existiert" \
  "requirements.txt|setup.py|setup.cfg|pyproject.toml"

check_file_contains \
  "Dependencies definiert" \
  "requirements.txt|setup.py" \
  "=="

summary
