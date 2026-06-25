#!/usr/bin/env bash
# Injects --dart-define flags for Flutter builds.
#
# CI (TestFlight): GitHub repository secrets → shell env → dart-define (no env files).
# Local: env/.env.local only — must mirror the same values as GitHub secrets (pre-launch).
#
# Usage: ./tool/dart_defines.sh dev flutter run
#        ./tool/dart_defines.sh prod flutter build ipa --release

set -euo pipefail

ENV_NAME="${1:-dev}"
shift

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DART_DEFINE_KEYS="SUPABASE_URL SUPABASE_PUBLISHABLE_KEY SUPABASE_ANON_KEY GOOGLE_MAPS_API_KEY"
REQUIRED_KEYS="SUPABASE_URL SUPABASE_PUBLISHABLE_KEY GOOGLE_MAPS_API_KEY"

SUPABASE_URL_VAL=""
SUPABASE_PUBLISHABLE_KEY_VAL=""
SUPABASE_ANON_KEY_VAL=""
GOOGLE_MAPS_API_KEY_VAL=""

val_for_key() {
  case "$1" in
    SUPABASE_URL) echo "$SUPABASE_URL_VAL" ;;
    SUPABASE_PUBLISHABLE_KEY) echo "$SUPABASE_PUBLISHABLE_KEY_VAL" ;;
    SUPABASE_ANON_KEY) echo "$SUPABASE_ANON_KEY_VAL" ;;
    GOOGLE_MAPS_API_KEY) echo "$GOOGLE_MAPS_API_KEY_VAL" ;;
  esac
}

set_val_for_key() {
  case "$1" in
    SUPABASE_URL) SUPABASE_URL_VAL="$2" ;;
    SUPABASE_PUBLISHABLE_KEY) SUPABASE_PUBLISHABLE_KEY_VAL="$2" ;;
    SUPABASE_ANON_KEY) SUPABASE_ANON_KEY_VAL="$2" ;;
    GOOGLE_MAPS_API_KEY) GOOGLE_MAPS_API_KEY_VAL="$2" ;;
  esac
}

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
    case " $DART_DEFINE_KEYS " in
      *" $key "*)
        if [[ -n "$val" && "$val" != *"YOUR_PROJECT_REF"* && "$val" != *"..." ]]; then
          set_val_for_key "$key" "$val"
        fi
        ;;
    esac
  done < "$file"
}

if [[ "${CI:-}" == "true" ]]; then
  for key in $DART_DEFINE_KEYS; do
    shell_val="${!key:-}"
    [[ -n "$shell_val" ]] && set_val_for_key "$key" "$shell_val"
  done
  missing=""
  for key in $REQUIRED_KEYS; do
    [[ -z "$(val_for_key "$key")" ]] && missing="${missing:+$missing }$key"
  done
  if [[ -n "$missing" ]]; then
    echo "error: CI requires GitHub secrets (not env files): $missing" >&2
    exit 1
  fi
else
  read_env_file "$ROOT/env/.env.local"
  for key in $DART_DEFINE_KEYS; do
    shell_val="${!key:-}"
    [[ -n "$shell_val" ]] && set_val_for_key "$key" "$shell_val"
  done
fi

DEFINES=(--dart-define="ENV=$ENV_NAME")
for key in $DART_DEFINE_KEYS; do
  val="$(val_for_key "$key")"
  [[ -n "$val" ]] && DEFINES+=(--dart-define="$key=$val")
done

cd "$ROOT"
exec "$@" "${DEFINES[@]}"
