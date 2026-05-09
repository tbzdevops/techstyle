#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 14 — Container Basics"
echo ""

check_file_exists \
  "Dockerfile existiert" \
  "Dockerfile"

check_file_contains \
  "Dockerfile verwendet ein Base-Image (FROM)" \
  "Dockerfile" \
  "^FROM"

check_file_exists \
  ".dockerignore existiert" \
  ".dockerignore"

check_file_contains \
  "Non-Root User oder USER-Anweisung vorhanden (Best Practice)" \
  "Dockerfile" \
  "^USER"

summary
