#!/usr/bin/env bash
# export.sh — Exporta o Akido Multiplayer para uma plataforma alvo
#
# Pré-requisito: configurar um preset de exportação no Godot Editor primeiro.
#
# Uso:
#   ./export.sh linux    → exporta para Linux (pasta builds/linux/)
#   ./export.sh windows  → exporta para Windows (pasta builds/windows/)
#   ./export.sh --help   → mostra esta ajuda
set -euo pipefail

GODOT="flatpak run org.godotengine.Godot"
PROJECT_PATH="$(cd "$(dirname "$0")" && pwd)"
BUILDS_DIR="$PROJECT_PATH/builds"

show_help() {
  grep '^#' "$0" | sed 's/^# //' | sed 's/^#//'
  exit 0
}

export_platform() {
  local platform="$1"
  local out_dir="$BUILDS_DIR/$platform"
  mkdir -p "$out_dir"

  case "$platform" in
    linux)
      local preset="Linux/X11"
      local out_file="$out_dir/AkidoMultiplayer.x86_64"
      ;;
    windows)
      local preset="Windows Desktop"
      local out_file="$out_dir/AkidoMultiplayer.exe"
      ;;
    *)
      echo "❌  Plataforma desconhecida: $platform"
      echo "    Opções: linux, windows"
      exit 1
      ;;
  esac

  echo "📦  Exportando para $platform → $out_file"
  $GODOT --path "$PROJECT_PATH" --headless \
    --export-release "$preset" "$out_file"
  echo "✅  Exportação concluída: $out_file"
}

case "${1:-}" in
  --help|-h) show_help ;;
  linux|windows) export_platform "$1" ;;
  *)
    echo "Uso: ./export.sh [linux|windows|--help]"
    exit 1
    ;;
esac
