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

In **Authentication → Providers**, enable **Email** (magic link / OTP) and **Google**.

### Redirect URL (required for Google OAuth)

Add this to **Authentication → URL configuration → Redirect URLs**:

```
triftly://login-callback
```

The app handles this via `AuthRedirect.url` (`lib/core/auth/auth_redirect.dart`) and native URL schemes (`triftly` on iOS/Android).

**iOS:** `AppDelegate` must call `super.application(_:open:options:)` so `app_links` / Supabase receive `triftly://login-callback` after Google OAuth.

### Google OAuth setup

1. [Google Cloud Console](https://console.cloud.google.com/) → create OAuth client (Web + iOS + Android as needed)
2. Supabase → **Authentication → Providers → Google** → paste Client ID + Secret
3. Add authorized redirect URI from Supabase dashboard to Google OAuth client
4. Smoke test: Me → Sign in → **Continue with Google**

## 3. App keys (client-safe only)

Stored in **GitHub repository secrets** — not in committed env files.

| Secret | Where to get it |
|--------|------------------|
| `SUPABASE_URL` | Project Settings → API |
| `SUPABASE_PUBLISHABLE_KEY` | Project Settings → API (`sb_publishable_…`) |
| `GOOGLE_MAPS_API_KEY` | Google Cloud Console |

Never put `sb_secret_…` / `service_role` in the app or git.

## 4. Local run

Create `env/.env.local` with the same values as GitHub secrets, then:

```bash
flutter run
```

## 5. TestFlight / CI

All app keys live in GitHub repository secrets:

- `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `GOOGLE_MAPS_API_KEY` — TestFlight
- `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD` — migrations only

The deploy workflow passes secrets into `flutter build ipa` via Fastlane.

## 6. Smoke test

1. Me → Sign in → email OTP
2. Create a trip while signed in
3. Confirm rows in **Table Editor** (`users`, `trips`, `buddies`, `trip_days`)
4. Sign in on a second device → trips pull down
