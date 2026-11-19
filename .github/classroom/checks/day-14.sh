#!/bin/bash
# PROJEKT Tag 14 — Container Teil 2: Deployment auf AWS (ECR + EC2).
# Geprüft wird genau ein Workflow, .github/workflows/deploy-aws.yml. Der
# Tag-13-Stand bringt eigene Workflows mit (container.yml, Blue-Green von
# Tag 8), die sonst ECR-, SSH- oder Compose-Kriterien erfüllen würden.
source .github/classroom/grade.sh

solution_for_id() {
  case "$1" in
    deploy-workflow) echo "Lege .github/workflows/deploy-aws.yml nach der Vorlage in der Tagesplanung an" ;;
    test-stage) echo "Stufe 1: Führe die Tests mit pytest aus, bevor das Image gebaut wird" ;;
    aws-credentials) echo "Nutze aws-actions/configure-aws-credentials mit secrets.AWS_ACCESS_KEY_ID, secrets.AWS_SECRET_ACCESS_KEY und secrets.AWS_SESSION_TOKEN" ;;
    registry-push) echo "Stufe 2: Melde dich mit aws-actions/amazon-ecr-login an und pushe das Image (push: true)" ;;
    sha-tag) echo "Stufe 2: Tagge das Image mit dem Commit-SHA (github.sha)" ;;
    stage-order) echo "Verkette die Jobs mit needs: (test → build-push → deploy)" ;;
    deploy-stage) echo "Stufe 3: Kopiere die Compose-Datei per ssh/scp auf die EC2-Instanz und führe dort docker compose pull und up aus" ;;
    smoke-test) echo "Stufe 3: Prüfe nach dem Deployment mit curl, ob der Shop antwortet (z. B. /healthz)" ;;
    prod-compose) echo "Lege docker-compose.prod.yml an: web nutzt image: (aus ECR) statt build:" ;;
    no-secrets) echo "Entferne Zugangsdaten und Schlüssel aus dem Repo und lege sie als GitHub Secrets ab" ;;
    deploy-doc) echo "Dokumentiere Ausgangsstand, Pipeline, Bedienung und Rollback in DEPLOYMENT.md" ;;
    *) echo "Überprüfe die Aufgabenstellung im README" ;;
  esac
}

WF=.github/workflows/deploy-aws.yml
PROD=docker-compose.prod.yml
DOC=DEPLOYMENT.md

# Echte AWS-Schlüssel oder private SSH-Schlüssel in versionierten Dateien.
# Der AWS-Beispielschlüssel (…EXAMPLE) aus den Security-Übungen zählt nicht.
committed_secrets() {
  git grep -hE '(AKIA|ASIA)[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY' -- . ':!.github/classroom' 2>/dev/null \
    | grep -v 'EXAMPLE'
}

echo "🔍 Prüfe Abnahmekriterien für Tag 14 — Container Teil 2 (Deployment auf AWS)"
echo ""

echo "── Auftrag 2: Pipeline ──"

check_file_exists "deploy-workflow" \
  "Pipeline: .github/workflows/deploy-aws.yml vorhanden" \
  "$WF"

check "stage-order" \
  "Pipeline: Jobs sind mit needs: verkettet (Test → Build → Deploy)" \
  "[ \$(grep -cE '^[[:space:]]+needs:' $WF 2>/dev/null) -ge 2 ]"

check "test-stage" \
  "Stufe 1: Tests laufen in der Pipeline (pytest)" \
  "grep -q 'pytest' $WF"

check "aws-credentials" \
  "Stufe 2: AWS-Zugang über GitHub Secrets inkl. Session-Token" \
  "grep -q 'configure-aws-credentials' $WF && grep -q 'secrets.AWS_SESSION_TOKEN' $WF"

check "registry-push" \
  "Stufe 2: Image wird nach AWS ECR gepusht" \
  "grep -q 'amazon-ecr-login' $WF && grep -qE 'push:[[:space:]]*true|docker push' $WF"

check "sha-tag" \
  "Stufe 2: Image-Tag enthält den Commit-SHA" \
  "grep -qE 'github\.sha|GITHUB_SHA' $WF"

check "deploy-stage" \
  "Stufe 3: Deployment per SSH mit Docker Compose auf EC2" \
  "grep -qE '(^|[[:space:]])(ssh|scp)[[:space:]]' $WF && grep -qE 'docker compose (pull|up)' $WF"

check "smoke-test" \
  "Stufe 3: Smoke-Test prüft den Shop nach dem Deployment (curl)" \
  "grep -qE 'curl[[:space:]]' $WF"

check "prod-compose" \
  "Server: docker-compose.prod.yml startet das Image aus der Registry (image: statt build:)" \
  "grep -qE '^[[:space:]]+image:' $PROD && ! grep -qE '^[[:space:]]+build:' $PROD"

check "no-secrets" \
  "Sicherheit: keine AWS-Schlüssel oder privaten SSH-Schlüssel im Repository" \
  "[ -f $WF ] && [ -z \"\$(committed_secrets)\" ]"

echo ""
echo "── Auftrag 3: Dokumentation ──"

check_file_exists "deploy-doc" \
  "Doku: DEPLOYMENT.md vorhanden" \
  "$DOC"

check "deploy-doc" \
  "Doku: Ausgangsstand, ECR, EC2 und Rollback beschrieben" \
  "grep -qiE 'day_13_solution|eigene[nms]? (team-)?(projekt|repo)' $DOC && grep -qi 'ecr' $DOC && grep -qi 'ec2' $DOC && grep -qi 'rollback' $DOC"

check "deploy-doc" \
  "Doku: DEPLOYMENT.md hat ausreichend Inhalt (mind. 150 Wörter)" \
  "[ \$(wc -w < $DOC 2>/dev/null) -ge 150 ]"

summary 14
