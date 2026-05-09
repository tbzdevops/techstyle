#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 4 — CI Grundlagen"
echo ""

check_workflow_exists \
  "CI Workflow-Datei existiert (.github/workflows/)" \
  "ci*.yml"

check_file_contains \
  "Workflow hat mindestens einen Job (jobs:)" \
  ".github/workflows/ci.yml" \
  "^jobs:"

check_file_contains \
  "Linting- oder Test-Schritt vorhanden" \
  ".github/workflows/ci.yml" \
  "lint|test|flake|pylint|pytest"

check_file_contains \
  "Trigger auf Push konfiguriert" \
  ".github/workflows/ci.yml" \
  "on:|push:"

summary
