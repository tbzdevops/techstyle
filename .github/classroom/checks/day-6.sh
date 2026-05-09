#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 6 — Testing & Code Quality"
echo ""

check_file_exists \
  "Test-Dateien vorhanden" \
  "tests/*.py|test_*.py|*_test.py"

check_file_contains \
  "pytest oder Unittest importiert" \
  "tests/*.py" \
  "pytest|unittest|test_"

check_file_contains \
  "Quality Gate konfiguriert (SonarQube/Codecov)" \
  ".github/workflows/ci.yml|sonar-project.properties" \
  "sonar|codecov|quality|coverage"

summary
