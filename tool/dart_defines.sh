#!/usr/bin/env bash
# Reads env/.env.<env> and appends --dart-define flags for Flutter builds.
# Usage: ./tool/dart_defines.sh dev flutter run
#        ./tool/dart_defines.sh prod flutter build ipa --release

set -euo pipefail

ENV_NAME="${1:-dev}"
shift

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/env/.env.$ENV_NAME"

DEFINES=(--dart-define="ENV=$ENV_NAME")

if [[ -f "$ENV_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%#*}"
    line="$(echo "$line" | xargs)"
    [[ -z "$line" ]] && continue
    key="${line%%=*}"
    val="${line#*=}"
    val="${val%\"}"
    val="${val#\"}"
    val="${val%\'}"
    val="${val#\'}"
    case "$key" in
      SUPABASE_URL|SUPABASE_PUBLISHABLE_KEY|SUPABASE_ANON_KEY|GOOGLE_MAPS_API_KEY)
        if [[ -n "$val" && "$val" != *"YOUR_PROJECT_REF"* && "$val" != *"..." ]]; then
          DEFINES+=(--dart-define="$key=$val")
        fi
        ;;
    esac
  done < "$ENV_FILE"
fi

for key in SUPABASE_URL SUPABASE_PUBLISHABLE_KEY SUPABASE_ANON_KEY GOOGLE_MAPS_API_KEY; do
  if [[ -n "${!key:-}" ]]; then
    DEFINES+=(--dart-define="$key=${!key}")
  fi
done

cd "$ROOT"
exec "$@" "${DEFINES[@]}"
