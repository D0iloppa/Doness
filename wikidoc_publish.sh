#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

WIKI_DOCS="wiki/wiki-docs"

# ── Options ──────────────────────────────────────────────────────────────────
SYNC_ONLY=false
NO_BUILD=false

for arg in "$@"; do
  case "$arg" in
    --sync-only) SYNC_ONLY=true ;;
    --no-build)  NO_BUILD=true ;;
    -h|--help)
      echo "Usage: $0 [--sync-only] [--no-build] [-h|--help]"
      echo "  --sync-only   Copy files only (skip docker rebuild)"
      echo "  --no-build    Restart container only (skip image rebuild)"
      exit 0
      ;;
  esac
done

# ── Sync: ai-docs -> wiki-docs ───────────────────────────────────────────────
# Add sync mappings here as the project grows.
# Example:
#   mkdir -p "$WIKI_DOCS/private/test"
#   cp ai-docs/TEST/progress.md "$WIKI_DOCS/private/test/progress.md"

echo "[sync] File sync complete."

if $SYNC_ONLY; then
  echo "[done] --sync-only: skipping docker."
  exit 0
fi

# ── Docker rebuild ───────────────────────────────────────────────────────────
if $NO_BUILD; then
  echo "[docker] Restarting wiki container (no rebuild)..."
  docker compose --profile wiki restart wiki
else
  echo "[docker] Rebuilding and restarting wiki..."
  docker compose --profile wiki up --build --no-deps -d wiki
fi

echo "[done] Wiki published."
