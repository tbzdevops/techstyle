#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 4 — CI Grundlagen"
echo ""

check_workflow_exists \
  "ci-workflow" \
  "CI Workflow-Datei existiert (.github/workflows/ci.yml)" \
  "ci*.yml"

check_file_contains \
  "ci-workflow" \
  "Workflow hat mindestens einen Job (jobs:)" \
  ".github/workflows/ci.yml" \
  "^jobs:"

check_file_contains \
  "linting" \
  "Linting-Schritt vorhanden (flake8/pylint)" \
  ".github/workflows/ci.yml" \
  "lint|flake|pylint"

check_file_contains \
  "testing" \
  "Test-Schritt vorhanden (pytest)" \
  ".github/workflows/ci.yml" \
  "test|pytest"

check_file_contains \
  "ci-workflow" \
  "Trigger auf Push konfiguriert" \
  ".github/workflows/ci.yml" \
  "on:|push:"

summary 4
