#!/bin/bash
# Gemeinsame Hilfsfunktionen für alle Check-Skripte mit detailliertem Feedback

PASS=0
FAIL=0

# Mapping von Checks zu Lösungshilfen
declare -A SOLUTIONS=(
  ["aws-setup"]="Stelle sicher, dass .env mit AWS-Credentials vorhanden ist"
  ["readme"]="Erstelle README.md mit Dokumentation zur App"
  ["git-ignore"]="Erstelle .gitignore mit Python-Einträgen (__pycache__, .venv, .env)"
  ["version"]="Erstelle setup.py, setup.cfg oder pyproject.toml"
  ["ci-workflow"]="Erstelle .github/workflows/ci.yml mit Push-Trigger"
  ["linting"]="Füge Linting-Schritt (flake8, pylint) im CI-Workflow hinzu"
  ["testing"]="Füge Test-Schritt (pytest) im CI-Workflow hinzu"
  ["cd-workflow"]="Erstelle .github/workflows/deploy.yml für Deployment"
  ["dockerfile"]="Erstelle Dockerfile mit FROM, RUN, CMD Anweisungen"
  ["security-scan"]="Integriere Security-Scan (Snyk, Trivy) im Workflow"
  ["k8s-manifests"]="Erstelle k8s/deployment.yaml mit Kubernetes-Manifesten"
  ["ai-integration"]="Erstelle AI_INTEGRATION.md mit Reflexion (mind. 100 Wörter)"
  ["helm-chart"]="Erstelle helm/Chart.yaml mit Helm-Konfiguration"
)

check() {
  local id="$1"
  local description="$2"
  local condition="$3"

  if eval "$condition" &>/dev/null; then
    echo "✅ $description"
    echo "::notice title=✅ $description::Check erfolgreich bestanden"
    PASS=$((PASS + 1))
  else
    echo "❌ $description"
    local solution="${SOLUTIONS[$id]:-Überprüfe die Anforderungen in der Dokumentation}"
    echo "::error title=❌ $description::$solution"
    FAIL=$((FAIL + 1))
  fi
}

check_file_exists() {
  local id="$1"
  local description="$2"
  local filepath="$3"
  check "$id" "$description" "[ -f '$filepath' ]"
}

check_file_contains() {
  local id="$1"
  local description="$2"
  local filepath="$3"
  local pattern="$4"
  check "$id" "$description" "grep -qiE '$pattern' '$filepath' 2>/dev/null"
}

check_workflow_exists() {
  local id="$1"
  local description="$2"
  local pattern="$3"
  check "$id" "$description" "ls .github/workflows/$pattern 2>/dev/null | head -1"
}

check_directory_exists() {
  local id="$1"
  local description="$2"
  local dirpath="$3"
  check "$id" "$description" "[ -d '$dirpath' ]"
}

check_command_in_file() {
  local id="$1"
  local description="$2"
  local filepath="$3"
  local command="$4"
  check "$id" "$description" "grep -qE \"$command\" '$filepath' 2>/dev/null"
}

summary() {
  local day="$1"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Tag $day — Zusammenfassung"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Erfüllt:    $PASS Kriterien"
  echo "❌ Fehlen:     $FAIL Kriterien"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if [ "$FAIL" -gt 0 ]; then
    echo ""
    echo "::error title=Tag $day nicht bestanden::$FAIL von $((PASS + FAIL)) Kriterien nicht erfüllt. Siehe Details oben."
    exit 1
  else
    echo ""
    echo "::notice title=✅ Tag $day bestanden::Gratuliere! Alle Kriterien erfüllt."
  fi
}
