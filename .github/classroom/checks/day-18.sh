#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 18 — Kubernetes Basics"
echo ""

check_directory_exists \
  "Kubernetes-Manifests-Verzeichnis existiert" \
  "k8s|kubernetes|manifests"

check_file_contains \
  "Kubernetes-Manifeste vorhanden" \
  "k8s/*.yaml|k8s/*.yml|kubernetes/*.yaml|manifests/*.yaml" \
  "apiVersion|kind|metadata"

check_file_contains \
  "ArgoCD oder GitOps-Konfiguration erwähnt" \
  "README.md|k8s/*.yaml|docs/*.md" \
  "argocd|gitops|deployment|application"

summary
