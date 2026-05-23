#!/usr/bin/env bash
# run.sh — Abre o Akido Multiplayer pelo Godot Editor
#
# Uso:
#   ./run.sh           → abre o editor
#   ./run.sh --game    → roda o jogo diretamente (sem abrir o editor)
#   ./run.sh --help    → mostra esta ajuda
set -euo pipefail

GODOT="flatpak run org.godotengine.Godot"
PROJECT_PATH="$(cd "$(dirname "$0")" && pwd)"

show_help() {
  grep '^#' "$0" | sed 's/^# //' | sed 's/^#//'
  exit 0
}

case "${1:-}" in
  --help|-h) show_help ;;
  --game)
    echo "🎮  Iniciando o jogo (sem editor)..."
    exec $GODOT --path "$PROJECT_PATH"
    ;;
  *)
    echo "🛠️   Abrindo o Godot Editor..."
    exec $GODOT --path "$PROJECT_PATH" -e
    ;;
esac
