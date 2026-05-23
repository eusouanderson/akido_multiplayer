#!/usr/bin/env bash
# test.sh — Executa a suite de testes do Akido Multiplayer
#
# Uso:
#   ./test.sh          → roda todos os testes
#   ./test.sh --watch  → roda em loop a cada 3 s (útil durante desenvolvimento)
#   ./test.sh --help   → mostra esta ajuda
set -euo pipefail

GODOT="flatpak run org.godotengine.Godot"
PROJECT_PATH="$(cd "$(dirname "$0")" && pwd)"
RUNNER="res://tests/test_runner.gd"

show_help() {
  grep '^#' "$0" | sed 's/^# //' | sed 's/^#//'
  exit 0
}

run_tests() {
  echo ""
  echo "🧪  Rodando testes — $(date '+%H:%M:%S')"
  echo "────────────────────────────────────────"
  $GODOT --path "$PROJECT_PATH" --script "$RUNNER"
  local exit_code=$?
  if [ $exit_code -eq 0 ]; then
    echo "✅  Todos os testes passaram!"
  else
    echo "❌  Alguns testes falharam (código: $exit_code)"
  fi
  return $exit_code
}

case "${1:-}" in
  --help|-h) show_help ;;
  --watch)
    echo "👀  Modo watch ativado — pressione Ctrl+C para parar."
    while true; do
      run_tests || true
      sleep 3
    done
    ;;
  *)
    run_tests
    ;;
esac
