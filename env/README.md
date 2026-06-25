# Environment config

**Single source of truth:** [GitHub repository secrets](https://github.com/yky32/triftly-app/settings/secrets/actions).

Committed `env/.env.*` files hold only non-secret structure (e.g. `APP_ENV`). Do not put API keys or Supabase credentials in git.

## GitHub secrets (app + backend)

| Secret | Used by |
|--------|---------|
| `SUPABASE_URL` | Migrations CI, TestFlight |
| `SUPABASE_PUBLISHABLE_KEY` | TestFlight |
| `GOOGLE_MAPS_API_KEY` | TestFlight |
| `SUPABASE_ACCESS_TOKEN` | Migrations CI only |
| `SUPABASE_DB_PASSWORD` | Migrations CI only |

## Local development

GitHub does not allow exporting secret values. For local runs, copy the example once:

```bash
cp env/.env.local.example env/.env.local
# Fill values (same as GitHub secrets)
```

Then:

```bash
./tool/dart_defines.sh dev flutter run
```

`env/.env.local` is gitignored. Shell environment variables override both files (same as CI).

## CI

- **TestFlight** — `.github/workflows/deploy-testflight.yml` injects secrets into Fastlane → `--dart-define`
- **Supabase migrations** — `.github/workflows/migrate-supabase.yml`

See also `supabase/README.md`.
