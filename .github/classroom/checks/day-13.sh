#!/bin/bash
source .github/classroom/grade.sh

echo "🔍 Prüfe Abnahmekriterien für Tag 13 — AI in DevOps"
echo ""

check_workflow_exists \
  "AI-Workflow existiert (.github/workflows/*ai*.yml oder ähnlich)" \
  "*ai*.yml"

check_file_contains \
  "GitHub Models API oder KI-Integration im Workflow" \
  ".github/workflows/*ai*.yml" \
  "models.inference|openai|copilot|claude|ollama|ai|llm"

check_file_exists \
  "AI_INTEGRATION.md Reflexionsdokument existiert" \
  "AI_INTEGRATION.md"

check \
  "AI_INTEGRATION.md hat ausreichend Inhalt (mind. 100 Wörter)" \
  "[ \$(wc -w < AI_INTEGRATION.md 2>/dev/null) -ge 100 ]"

check_file_contains \
  "AI_INTEGRATION.md enthält Abschnitt zu Grenzen/Risiken" \
  "AI_INTEGRATION.md" \
  "grenz|risiko|limit|schwäche|sicherheit|security|prompt|inject"

summary
