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
6. `migrations/006_trip_share_join.sql`

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

**iOS:** Google sign-in uses `ASWebAuthenticationSession` (in-app sheet). It auto-returns to Triftly on `triftly://login-callback` without opening Safari or leaving a browser tab. `AppDelegate` still forwards deep links via `super.application(_:open:options:)` for cold-start / Android.

### Google OAuth setup

1. [Google Cloud Console](https://console.cloud.google.com/) → create OAuth client (Web + iOS + Android as needed)
2. Supabase → **Authentication → Providers → Google** → paste Client ID + Secret
3. Add authorized redirect URI from Supabase dashboard to Google OAuth client
4. Smoke test: Me → Sign in → **Continue with Google**

### Auth debug logs (local dev)

In debug builds, auth events print with a fixed prefix — filter the console with **`🔐 AUTH`**:

| Glyph | Meaning |
|-------|---------|
| `🌐` | OAuth browser flow |
| `🔗` | Deep link received |
| `👤` | Session / auth state |
| `☁️` | Cloud trip sync |
| `✅` | Success |
| `❌` | Error |
| `·` | General info |

Example: `🔐 AUTH ✅ │ Sign-in successful: you@email.com (uuid)`

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

## 6. Pilot smoke checklist

Run this before each TestFlight build or after schema/auth changes.

### Sign-in & session

- [ ] Me → Sign in → email OTP completes
- [ ] Me → Sign in → **Continue with Google** returns to app (no Safari tab left open)
- [ ] Console filter `🔐 AUTH` shows `✅ Sign-in successful`
- [ ] Me identity island shows your email / name (not Guest)

### Create & sync (signed in)

- [ ] Trips → **+** → create a trip → appears in list immediately
- [ ] Trips tab shows **Synced just now** (or similar) after pull
- [ ] Supabase **Table Editor**: rows in `users`, `trips`, `buddies`, `trip_days`
- [ ] Edit trip name on device A → pull-to-refresh on device B → change appears

### Offline / failure handling

- [ ] Create trip while **not** signed in → sheet shows *Sign in to sync this trip across your devices*
- [ ] Airplane mode → pull-to-refresh → red **Could not sync trips** banner with **Retry**
- [ ] Me → Data → **Trip sync** row shows error; tap row (chevron) or Trips **Retry** recovers when online

### Second device

- [ ] Sign in with same account on device B → trips from device A appear after sync
- [ ] Create trip on B → appears on A after pull-to-refresh

### Share links (join via WhatsApp / Messages)

- [ ] Trip detail → Share → iOS share sheet → send link via WhatsApp
- [ ] Buddy taps `https://triftly.app/s/{token}` → **Triftly opens** (not Safari stuck)
- [ ] Preview shows full trip (plan, spend, map)
- [ ] Tap **Join** → sign in if needed → trip appears in **Trips** tab
- [ ] Second device: same account → joined trip syncs after pull
- [ ] Host `web/.well-known/apple-app-site-association` on `triftly.app` (see `web/.well-known/`)

### Quick SQL spot-check

```sql
select id, name, owner_id, updated_at from trips order by updated_at desc limit 5;
```
