#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 10 — Alerting & Dashboards"
echo ""

check_file_contains \
  "Alert-Rules oder Alert-Konfiguration vorhanden" \
  "prometheus/rules.yml|rules.yml|app.py|README.md" \
  "alert|rule|threshold|trigger"

check_file_exists \
  "Dashboard-Definition oder Grafana-Export vorhanden" \
  "grafana/dashboards/*.json|dashboards/*.json"

check_file_contains \
  "Alerting-Dokumentation existiert" \
  "README.md|docs/monitoring.md|docs/alerts.md" \
  "alert|notification|on-call"

summary
