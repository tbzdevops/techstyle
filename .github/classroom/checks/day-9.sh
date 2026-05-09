#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 9 — Monitoring Grundlagen (Prometheus/Grafana)"
echo ""

check_file_exists \
  "Prometheus-Konfiguration oder Metriken vorhanden" \
  "prometheus.yml|monitoring/prometheus.yml|docs/monitoring.md"

check_file_contains \
  "Metrics oder Prometheus erwähnt" \
  "README.md|docs/*.md|app.py" \
  "prometheus|metrics|scrape|monitoring"

check_file_exists \
  "Grafana-Konfiguration oder Dashboard-Definition" \
  "grafana/dashboards/*.json|dashboards/*.json|monitoring/grafana.yml"

summary
