# Environment config

**Single source of truth:** [GitHub repository secrets](https://github.com/yky32/triftly-app/settings/secrets/actions).

Pre-launch: **one** Supabase project and API keys for both local dev and TestFlight.

| Layer | Where keys come from |
|-------|----------------------|
| **TestFlight (CI)** | GitHub secrets only — env files are never read |
| **Local dev** | `env/.env.local` — must match GitHub secrets exactly |

Committed `env/.env.dev` / `.stag` / `.prod` hold only non-secret metadata (`APP_ENV`). No API keys in git.

## GitHub secrets

| Secret | TestFlight | Local | Migrations |
|--------|------------|-------|------------|
| `SUPABASE_URL` | ✓ | mirror in `.env.local` | ✓ |
| `SUPABASE_PUBLISHABLE_KEY` | ✓ | mirror in `.env.local` | — |
| `GOOGLE_MAPS_API_KEY` | ✓ | mirror in `.env.local` | — |
| `SUPABASE_ACCESS_TOKEN` | — | — | ✓ |
| `SUPABASE_DB_PASSWORD` | — | — | ✓ |

## Local setup (once)

```bash
cp env/.env.local.example env/.env.local
# Paste the same values as GitHub secrets
./tool/dart_defines.sh dev flutter run
```

`env/.env.local` is gitignored. Shell env vars override `.env.local` (same precedence as CI).

## CI

- **TestFlight** — `.github/workflows/deploy-testflight.yml` validates secrets, then Fastlane passes them as `--dart-define` (skips all env files when `CI=true`)
- **Supabase migrations** — `.github/workflows/migrate-supabase.yml`

See also `supabase/README.md`.
