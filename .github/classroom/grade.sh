#!/bin/bash
# Gemeinsame Hilfsfunktionen für alle Check-Skripte

PASS=0
FAIL=0

check() {
  local description="$1"
  local condition="$2"

  if eval "$condition" &>/dev/null; then
    echo "✅ $description"
    PASS=$((PASS + 1))
  else
    echo "❌ $description"
    FAIL=$((FAIL + 1))
  fi
}

check_file_exists() {
  local description="$1"
  local filepath="$2"
  check "$description" "[ -f '$filepath' ]"
}

check_file_contains() {
  local description="$1"
  local filepath="$2"
  local pattern="$3"
  check "$description" "grep -qiE '$pattern' '$filepath' 2>/dev/null"
}

check_workflow_exists() {
  local description="$1"
  local pattern="$2"
  check "$description" "ls .github/workflows/$pattern 2>/dev/null | head -1"
}

check_directory_exists() {
  local description="$1"
  local dirpath="$2"
  check "$description" "[ -d '$dirpath' ]"
}

check_command_in_file() {
  local description="$1"
  local filepath="$2"
  local command="$3"
  check "$description" "grep -qE \"$command\" '$filepath' 2>/dev/null"
}

summary() {
  echo ""
  echo "─────────────────────────────────────"
  echo "Resultat: $PASS von $((PASS + FAIL)) Kriterien erfüllt"
  echo "─────────────────────────────────────"
  if [ "$FAIL" -gt 0 ]; then
    exit 1
  fi
}
