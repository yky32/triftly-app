# Deploy to TestFlight — Troubleshooting Summary

> PR-style summary of CI signing and TestFlight deploy fixes merged to `main` (June 2026).

## Summary

- CI **imports and reuses** a single Apple Distribution `.p12` from GitHub secrets instead of creating a new portal cert every deploy ([#44](https://github.com/yky32/triftly-app/pull/44)).
- Signing uses a **dedicated CI keychain** so `xcodebuild` / `codesign` do not hang waiting for keychain prompts.
- **Build numbers** are synced with App Store Connect before upload, with automatic retry on duplicate build errors.
- End-to-end deploy (sign → archive → IPA → TestFlight upload) completes in **~5–10 minutes** on `macos-26` when healthy.

---

## Timeline of issues and fixes

| Symptom | Root cause | Fix (commit / PR) |
|--------|------------|-------------------|
| `MAC verification failed during PKCS12 import` | `.p12` exported with OpenSSL without `-legacy`; macOS `security import` rejected it | Re-export from Keychain Access, or `openssl pkcs12 -export -legacy` |
| Signing passed but archive hung **4 hours** until timeout | Imported cert could not be used by `codesign` non-interactively (login keychain partition list) | Dedicated `triftly-ci.keychain` (`2110a51`) |
| `Failed to configure keychain… empty password` on login keychain | First keychain fix targeted login keychain; GHA runners reject empty-password partition updates | Replaced with dedicated CI keychain (`2110a51`) |
| Upload failed: build `110` already used | `pubspec.yaml` incremented locally only; ASC already had that build | Query ASC latest build + retry on duplicate (`36c89eb`) |
| Runs show `cancelled` after 3–15 min | New push to `main` cancels in-progress deploy (`cancel-in-progress: true`) | Wait for deploy to finish before merging; or use `workflow_dispatch` |

---

## Architecture (current `main`)

```
Prepare App Store signing
  ├── prune_excess_certificates_for_ci   (Development certs only)
  ├── import_distribution_certificate_for_ci!
  │     ├── Create ~/Library/Keychains/triftly-ci.keychain-db
  │     ├── Import IOS_DISTRIBUTION_CERT_BASE64 (.p12)
  │     └── set-key-partition-list (codesign allowed)
  └── get_provisioning_profile (force: false, matches portal cert)

Deploy to TestFlight
  ├── increment_build_number_in_pubspec (max(pubspec, ASC latest) + 1)
  ├── flutter build ipa
  ├── upload_to_testflight
  └── commit_and_push_build_number [skip ci] on success
```

---

## One-time setup: stable Distribution cert

### Rule

Apple Developer portal downloads are **`.cer` only** (no private key).  
CI needs **`.p12`** = certificate **+** private key. Never upload a portal `.cer` renamed as `.p12`.

### Steps

1. **Create cert on your Mac** (keeps private key local):
   ```bash
   cd ios
   bundle exec fastlane ios setup_appstore_signing
   ```
2. **Export from Keychain Access** → My Certificates → **Apple Distribution: KAI YIN YU (3G34999H3A)** → Export as `.p12`.
3. **Verify locally**:
   ```bash
   security import triftly_distribution.p12 \
     -k ~/Library/Keychains/login.keychain-db \
     -P 'YOUR_EXPORT_PASSWORD' \
     -T /usr/bin/codesign
   security find-identity -v -p codesigning | grep "Apple Distribution"
   ```
4. **Set GitHub secrets** (`yky32/triftly-app`):
   ```bash
   gh secret set IOS_DISTRIBUTION_CERT_BASE64 -R yky32/triftly-app \
     < <(base64 -i triftly_distribution.p12 | tr -d '\n')
   gh secret set IOS_DISTRIBUTION_CERT_PASSWORD -R yky32/triftly-app
   ```
5. **Portal hygiene**: keep **one** valid Apple Distribution cert; revoke orphans without a matching private key.

### Required secrets (CI)

| Secret | Purpose |
|--------|---------|
| `IOS_DISTRIBUTION_CERT_BASE64` | Distribution `.p12` (base64, single line) |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | Export password for the `.p12` |
| `APP_STORE_CONNECT_API_KEY_ID` | ASC API key |
| `APP_STORE_CONNECT_ISSUER_ID` | ASC issuer ID |
| `APP_STORE_CONNECT_API_KEY_CONTENT` | `.p8` key body |
| `GH_PAT` | Checkout with permissions for build-number auto-commit |

---

## Troubleshooting guide

### Prepare App Store signing fails

| Log | Action |
|-----|--------|
| `MAC verification failed during PKCS12 import` | Wrong password or bad `.p12` format. Re-export from Keychain Access. |
| `No Apple Distribution identity in keychain` | Secrets missing/empty, or import failed. Re-set both `IOS_DISTRIBUTION_*` secrets. |
| `No valid DISTRIBUTION certificate found` | No valid cert on Apple Developer portal. Create one on Mac and export `.p12`. |
| Profile / cert mismatch | Portal cert serial must match imported `.p12`. Revoke extra Distribution certs. |

### Deploy step hangs (no log output for 30+ min)

| Log | Action |
|-----|--------|
| Stuck after `Archiving com.triftly...` | Usually keychain / codesign. Confirm `triftly-ci.keychain` fix is on `main`. |
| Hits **240 min** timeout | Same as above, or investigate `pod install` / Xcode slowness. |
| `Terminate orphan process: xcodebuild` | Runner killed hung build at timeout. |

**Healthy archive timing:** ~2–4 minutes on current runners (not hours).

### Upload fails

| Log | Action |
|-----|--------|
| `bundle version must be higher than… '110'` | Duplicate build. Fixed by ASC sync (`36c89eb`); re-run deploy. |
| `Couldn't find app` | App missing in App Store Connect; run `bundle exec fastlane ios create_app`. |

### Run cancelled unexpectedly

- Workflow uses `concurrency: cancel-in-progress: true`.
- Any new push to `main` **cancels** the active TestFlight job.
- Avoid merging multiple PRs during a long deploy.

---

## Key files

| Path | Role |
|------|------|
| `.github/workflows/deploy-testflight.yml` | CI workflow (240 min timeout, `macos-26`) |
| `ios/fastlane/Fastfile` | Signing import, keychain, build, upload, build-number logic |
| `pubspec.yaml` | `version: x.y.z+build` — CI bumps build before archive |

### Relevant `main` commits

- `c8f4a47` — PR #44: reuse imported Distribution cert on CI
- `d2c56bf` — First keychain partition attempt (superseded)
- `2110a51` — Dedicated CI keychain for cert import
- `36c89eb` — ASC-aware build number increment + duplicate upload retry

---

## Test plan

- [ ] `Prepare App Store signing` logs `Imported distribution certificate into CI keychain`
- [ ] `Prepare App Store signing` logs `Reusing imported Apple Distribution certificate on CI`
- [ ] No `MAC verification failed` during import
- [ ] `flutter build ipa` completes in &lt; 15 minutes
- [ ] Upload succeeds without duplicate build error
- [ ] Second deploy on `main` does **not** create a new Distribution cert on Apple Developer
- [ ] `pubspec.yaml` build number auto-committed with `[skip ci]` after successful upload

---

## Golden rules

| Do | Don't |
|----|--------|
| Keep **one** Distribution cert on the portal | Let CI rotate Distribution certs (pre–#44 behaviour) |
| Export `.p12` from Keychain Access | Download `.cer` from portal and rename to `.p12` |
| Update both `IOS_DISTRIBUTION_*` secrets together | Commit `.p12` / certs to git |
| Wait for deploy to finish before merging to `main` | Push to `main` during an active deploy (cancels it) |
| Store `.p12` + password in a password manager | Share secrets in chat or repo |

---

## Manual deploy trigger

```bash
gh workflow run deploy-testflight.yml -R yky32/triftly-app --ref main
```

Monitor: [Actions → Deploy to TestFlight](https://github.com/yky32/triftly-app/actions/workflows/deploy-testflight.yml)
