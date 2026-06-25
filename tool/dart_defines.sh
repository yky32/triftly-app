#!/usr/bin/env bash
# Writes env/dart_defines.json then runs Flutter with --dart-define-from-file.
#
# Local: reads env/.env.local (mirror of GitHub secrets).
# CI: reads SUPABASE_* / GOOGLE_MAPS_* from shell env (GitHub secrets).
#
# Usage: ./tool/dart_defines.sh dev flutter run

set -euo pipefail

ENV_NAME="${1:-dev}"
shift

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEFINES_FILE="$ROOT/env/dart_defines.json"
REQUIRED_KEYS="SUPABASE_URL SUPABASE_PUBLISHABLE_KEY GOOGLE_MAPS_API_KEY"

python3 "$ROOT/tool/sync_dart_defines.py" "$ENV_NAME"

if [[ "${CI:-}" == "true" ]]; then
  missing=""
  for key in $REQUIRED_KEYS; do
    if ! python3 -c "import json,sys; d=json.load(open('$DEFINES_FILE')); sys.exit(0 if d.get('$key') else 1)"; then
      missing="${missing:+$missing }$key"
    fi
  done
  if [[ -n "$missing" ]]; then
    echo "error: CI requires GitHub secrets (not env files): $missing" >&2
    exit 1
  fi
fi

cd "$ROOT"
exec "$@" --dart-define-from-file="$DEFINES_FILE"
