#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 16 — Sammelcheck (Monitoring, Security, Container)"
echo ""

check \
  "Monitoring-Konfiguration vorhanden (Tag 9-10)" \
  "[ -f 'prometheus.yml' ] || [ -f 'monitoring/prometheus.yml' ] || grep -rq 'prometheus' ."

check_workflow_exists \
  "Security-Workflow vorhanden (Tag 11)" \
  "security*.yml"

check_file_exists \
  "Dockerfile vorhanden (Tag 14)" \
  "Dockerfile"

check_workflow_exists \
  "Container-Pipeline vorhanden (Tag 15)" \
  "container*.yml|build*.yml|docker*.yml"

summary
