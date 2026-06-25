# Supabase setup (Triftly)

## 1. Migrations (automatic on `main`)

Pushes to `main` that touch `supabase/migrations/**` run the **Supabase migrations** GitHub Action (`.github/workflows/migrate-supabase.yml`). You can also trigger it manually under **Actions → Supabase migrations → Run workflow**.

### GitHub secrets (migrations)

| Secret | Where to get it |
|--------|------------------|
| `SUPABASE_URL` | Already set (`https://….supabase.co`) |
| `SUPABASE_ACCESS_TOKEN` | [Account → Access Tokens](https://supabase.com/dashboard/account/tokens) → Generate |
| `SUPABASE_DB_PASSWORD` | Project **Settings → Database** → Database password (set on project create) |

### Manual / local (optional)

```bash
npx supabase link --project-ref YOUR_REF
npx supabase db push
```

Migration order:

1. `migrations/001_initial_schema.sql`
2. `migrations/002_sync_columns_and_rls.sql`
3. `migrations/003_auth_profile_trigger.sql`
4. `migrations/004_shared_trip_bundle.sql`
5. `migrations/005_rename_profiles_to_users.sql` — only if `public.profiles` already exists

**Already ran SQL by hand?** Mark versions as applied so CI does not re-run them:

```bash
npx supabase migration repair --status applied 001 002 003 004
```

## 2. Auth

In **Authentication → Providers**, enable **Email** (magic link / OTP).

## 3. App keys (client-safe only)

Stored in **GitHub repository secrets** — not in committed env files.

| Secret | Where to get it |
|--------|------------------|
| `SUPABASE_URL` | Project Settings → API |
| `SUPABASE_PUBLISHABLE_KEY` | Project Settings → API (`sb_publishable_…`) |
| `GOOGLE_MAPS_API_KEY` | Google Cloud Console |

Never put `sb_secret_…` / `service_role` in the app or git.

## 4. Local run

Copy `env/.env.local.example` → `env/.env.local` and fill the same values as GitHub secrets, then:

```bash
./tool/dart_defines.sh dev flutter run
```

## 5. TestFlight / CI

All app keys live in GitHub repository secrets (see `env/README.md`):

- `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_MAPS_API_KEY` — TestFlight
- `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD` — migrations only

The deploy workflow passes secrets into `flutter build ipa` via Fastlane.

## 6. Smoke test

1. Me → Sign in → email OTP
2. Create a trip while signed in
3. Confirm rows in **Table Editor** (`users`, `trips`, `buddies`, `trip_days`)
4. Sign in on a second device → trips pull down
