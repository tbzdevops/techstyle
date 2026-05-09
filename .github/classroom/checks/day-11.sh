#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 11 — DevSecOps"
echo ""

check_workflow_exists \
  "Security-Workflow existiert" \
  "security*.yml"

check_file_contains \
  "Sicherheitsprüfung im Workflow vorhanden (SAST/SCA)" \
  ".github/workflows/security*.yml" \
  "snyk|trivy|sonarqube|security|scan|sast"

check_file_contains \
  "Security-Secret oder Token referenziert" \
  ".github/workflows/security*.yml" \
  "token|secret|key|auth"

check_file_contains \
  "Security-Dokumentation existiert" \
  "README.md|SECURITY.md|docs/security.md" \
  "security|vulnerability|scan|policy"

summary
