#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 15 — Container Pipeline"
echo ""

check_workflow_exists \
  "Container/Build-Workflow existiert" \
  "container*.yml|build*.yml|docker*.yml"

check_file_contains \
  "Docker Image Build im Workflow" \
  ".github/workflows/container*.yml|.github/workflows/build*.yml|.github/workflows/docker*.yml" \
  "docker|build|image|push|registry"

check_file_contains \
  "Registry-Push oder Image Scanning vorhanden" \
  ".github/workflows/container*.yml|.github/workflows/build*.yml" \
  "push|scan|registry|dockerhub|ghcr"

summary
