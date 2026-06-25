# Supabase setup (Triftly)

## 1. Run migrations

In the Supabase SQL editor (or CLI), run in order:

1. `migrations/001_initial_schema.sql`
2. `migrations/002_sync_columns_and_rls.sql`
3. `migrations/003_auth_profile_trigger.sql`

## 2. Auth

In **Authentication → Providers**, enable **Email** (magic link / OTP).

## 3. App keys (client-safe only)

From **Project Settings → API**:

| Variable | Where to use | Never commit |
|----------|----------------|--------------|
| `SUPABASE_URL` | Flutter `--dart-define`, GitHub secret | — |
| `SUPABASE_PUBLISHABLE_KEY` (`sb_publishable_…`) | Flutter `--dart-define`, `env/.env.*` | — |
| `sb_secret_…` / `service_role` | Server / Edge Functions only | **Do not** put in the app or git |

## 4. Local run

Set `SUPABASE_URL` in `env/.env.dev`, then:

```bash
./tool/dart_defines.sh dev flutter run
```

Or pass defines manually:

```bash
flutter run \
  --dart-define=ENV=dev \
  --dart-define=SUPABASE_URL=https://YOUR_REF.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

## 5. TestFlight / CI

Add GitHub repository secrets:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`

The deploy workflow passes them into `flutter build ipa` via Fastlane.

## 6. Smoke test

1. Me → Sign in → email OTP
2. Create a trip while signed in
3. Confirm rows in **Table Editor** (`trips`, `buddies`, `trip_days`)
4. Sign in on a second device → trips pull down
