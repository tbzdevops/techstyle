#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 19 — ArgoCD & Helm"
echo ""

check_file_contains \
  "ArgoCD Application-Definitionen vorhanden" \
  "k8s/*.yaml|argocd/*.yaml|apps/*.yaml|README.md" \
  "argocd|Application|apiVersion.*argoproj"

check_directory_exists \
  "Helm Chart-Verzeichnis vorhanden" \
  "helm|charts"

check_file_contains \
  "Helm Chart.yaml oder values.yaml vorhanden" \
  "helm/Chart.yaml|helm/values.yaml|charts/Chart.yaml" \
  "name|version|chart"

summary
