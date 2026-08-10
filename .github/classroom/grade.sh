#!/bin/bash
# Gemeinsame Hilfsfunktionen für alle Check-Skripte mit detailliertem Feedback

PASS=0
FAIL=0

resolve_day() {
  local ref="${GITHUB_REF_NAME:-${GITHUB_HEAD_REF:-${GITHUB_REF:-}}}"

  if [ -n "${CLASSROOM_DAY:-}" ]; then
    echo "${CLASSROOM_DAY}"
    return 0
  fi

  if [ -z "$ref" ]; then
    return 0
  fi

  local normalized
  normalized="$(echo "$ref" | tr '[:upper:]' '[:lower:]')"

  if [[ "$normalized" =~ (^|[^0-9])(tag|day)?0*([1-9][0-9]?)($|[^0-9]) ]]; then
    echo "${BASH_REMATCH[3]}"
    return 0
  fi

  if [[ "$normalized" =~ ([0-9]{1,2}) ]]; then
    echo "${BASH_REMATCH[1]}"
    return 0
  fi

  return 0
}

run_day_checks() {
  local day
  day="$(resolve_day)"

  if [ -z "$day" ]; then
    echo "ℹ️ Keine Tag-Nummer erkannt. Überspringe automatische Auswertung."
    return 0
  fi

  local check_file=".github/classroom/checks/day-${day}.sh"

  if [ ! -f "$check_file" ]; then
    echo "::notice title=Keine Checks::Für Tag $day sind keine Checks definiert"
    return 0
  fi

  echo "🔍 Prüfe Abnahmekriterien für Tag $day"
  echo ""

  chmod +x "$check_file"
  bash "$check_file"
}

solution_for_id() {
  local id="$1"
  case "$id" in
    aws-setup)
      echo "Stelle sicher, dass .env mit AWS-Credentials vorhanden ist"
      ;;
    readme)
      echo "Erstelle README.md mit Dokumentation zur App"
      ;;
    git-ignore)
      echo "Erstelle .gitignore mit Python-Einträgen (__pycache__, .venv, .env)"
      ;;
    version)
      echo "Erstelle setup.py, setup.cfg oder pyproject.toml"
      ;;
    ci-workflow)
      echo "Erstelle .github/workflows/ci.yml mit Push-Trigger"
      ;;
    linting)
      echo "Füge Linting-Schritt (flake8, pylint) im CI-Workflow hinzu"
      ;;
    testing)
      echo "Füge Test-Schritt (pytest) im CI-Workflow hinzu"
      ;;
    cd-workflow)
      echo "Erstelle .github/workflows/deploy.yml für Deployment"
      ;;
    dockerfile)
      echo "Erstelle Dockerfile mit FROM, RUN, CMD Anweisungen"
      ;;
    security-scan)
      echo "Integriere Security-Scan (Snyk, Trivy) im Workflow"
      ;;
    k8s-manifests)
      echo "Erstelle k8s/deployment.yaml mit Kubernetes-Manifesten"
      ;;
    ai-integration)
      echo "Erstelle AI_INTEGRATION.md mit Reflexion (mind. 100 Wörter)"
      ;;
    helm-chart)
      echo "Erstelle helm/Chart.yaml mit Helm-Konfiguration"
      ;;
    *)
      echo "Überprüfe die Anforderungen in der Dokumentation"
      ;;
  esac
}

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
    local solution
    solution="$(solution_for_id "$id")"
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

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_day_checks "$@"
fi
