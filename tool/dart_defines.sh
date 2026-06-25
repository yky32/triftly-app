#!/usr/bin/env bash
# Reads env/.env.<env> + env/.env.local and appends --dart-define flags for Flutter.
# CI: secrets are injected as shell env vars (GitHub Actions).
# Local: copy env/.env.local.example → env/.env.local and fill values.
#
# Usage: ./tool/dart_defines.sh dev flutter run
#        ./tool/dart_defines.sh prod flutter build ipa --release

set -euo pipefail

ENV_NAME="${1:-dev}"
shift

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DART_DEFINE_KEYS=(SUPABASE_URL SUPABASE_PUBLISHABLE_KEY SUPABASE_ANON_KEY GOOGLE_MAPS_API_KEY)

declare -A VALUES

read_env_file() {
  local file="$1"
  [[ -f "$file" ]] || return 0

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
    for allowed in "${DART_DEFINE_KEYS[@]}"; do
      if [[ "$key" == "$allowed" && -n "$val" && "$val" != *"YOUR_PROJECT_REF"* && "$val" != *"..." ]]; then
        VALUES["$key"]="$val"
      fi
    done
  done < "$file"
}

read_env_file "$ROOT/env/.env.$ENV_NAME"
read_env_file "$ROOT/env/.env.local"

for key in "${DART_DEFINE_KEYS[@]}"; do
  if [[ -n "${!key:-}" ]]; then
    VALUES["$key"]="${!key}"
  fi
done

DEFINES=(--dart-define="ENV=$ENV_NAME")
for key in "${DART_DEFINE_KEYS[@]}"; do
  val="${VALUES[$key]:-}"
  [[ -n "$val" ]] && DEFINES+=(--dart-define="$key=$val")
done

cd "$ROOT"
exec "$@" "${DEFINES[@]}"
