# Fastlane Menu - Depozio

Complete guide to all available Fastlane lanes for the Depozio Flutter app.

## 📋 Table of Contents

- [Two-factor authentication (2FA)](#two-factor-authentication-2fa)
- [iOS Lanes](#ios-lanes)
- [Android Lanes](#android-lanes)
- [Common Lanes](#common-lanes)

---

## Two-factor authentication (2FA)

When running Fastlane in a **non-interactive session** (e.g. CI, server, or SSH without a TTY), Apple may require 2FA and Fastlane will prompt for input. To automate this:

1. **SMS code to a trusted number**  
   Set the environment variable so Fastlane auto-selects SMS and uses your phone number:

   ```bash
   export SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER=+852XXXXXXXX
   ```

   In **local** use, this can be set in `ios/fastlane/.env.default` (that file is gitignored).  
   In **CI**, add `SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER` as a secret with your trusted phone number (e.g. `+85268215274`).

2. **Docs:** [Spaceship Authentication – auto-select SMS](https://github.com/fastlane/fastlane/blob/master/spaceship/docs/Authentication.md#auto-select-sms-via-spaceship_2fa_sms_default_phone_number)

---

## 🍎 iOS Lanes

### `ios build_debug`

**Purpose:** Build the iOS app in debug mode for development and testing.

**What it does:**
- Fetches Flutter dependencies
- Builds iOS app in debug mode (no code signing required)
- Outputs an unsigned `.app` file for simulator or device testing

**Usage:**
```bash
cd ios
bundle exec fastlane ios build_debug
```

**Output Location:**
```
build/ios/Debug-iphoneos/Runner.app
```

**When to use:**
- Local development and testing
- Quick builds without code signing
- Testing on simulator or development devices

---

### `ios build_release`

**Purpose:** Build the iOS app in release mode (unsigned) for testing or further processing.

**What it does:**
- Fetches Flutter dependencies
- Builds iOS app in release mode (optimized, but unsigned)
- Creates a release build without code signing

**Usage:**
```bash
cd ios
bundle exec fastlane ios build_release
```

**Output Location:**
```
build/ios/Release-iphoneos/Runner.app
```

**When to use:**
- Testing release builds locally
- Preparing for manual code signing
- Performance testing with release optimizations

---

### `ios build_ipa`

**Purpose:** Build a signed IPA file for distribution (development, ad-hoc, app-store, or enterprise).

**What it does:**
- Fetches Flutter dependencies
- Builds iOS app in release mode
- Creates a signed IPA file using Xcode's archive and export process
- Supports multiple export methods

**Usage:**
```bash
# Development IPA (default - for testing on registered devices)
bundle exec fastlane ios build_ipa

# Ad-Hoc distribution (for specific devices)
bundle exec fastlane ios build_ipa export_method:ad-hoc

# App Store submission (for TestFlight/App Store)
bundle exec fastlane ios build_ipa export_method:app-store

# Enterprise distribution
bundle exec fastlane ios build_ipa export_method:enterprise
```

**Output Location:**
```
build/ios/ipa/Runner.ipa
build/ios/ipa/Runner.app.dSYM.zip  (debug symbols)
```

**Export Methods:**
- `development` - For testing on registered development devices
- `ad-hoc` - For distribution to specific devices via UDID
- `app-store` - For TestFlight and App Store submission
- `enterprise` - For enterprise distribution (requires enterprise account)

**When to use:**
- Creating installable IPA files
- Preparing for TestFlight upload
- Distributing to testers
- App Store submission preparation

---

### `ios upload_testflight`

**Purpose:** Build an IPA and upload it to TestFlight for beta testing.

**What it does:**
- Builds IPA with `app-store` export method (required for TestFlight)
- Uploads the IPA to App Store Connect
- Waits for TestFlight processing to complete
- Configures for internal testing (can be changed for external)

**Usage:**
```bash
# Build and upload to TestFlight
bundle exec fastlane ios upload_testflight

# Upload existing IPA (skip build)
bundle exec fastlane ios upload_testflight skip_build:true
```

**Configuration:**
- `skip_waiting_for_build_processing: false` - Waits for processing
- `skip_submission: true` - Doesn't auto-submit for review
- `distribute_external: false` - Internal testing only
- `notify_external_testers: false` - No automatic notifications

**When to use:**
- Uploading beta builds to TestFlight
- Distributing to internal testers
- Preparing for external beta testing

**Requirements:**
- App Store Connect API access or Apple ID authentication
- Valid App Store distribution certificate and provisioning profile
- App must be configured in App Store Connect

---

### `ios increment_build`

**Purpose:** Automatically increment the build number in the Xcode project.

**What it does:**
- Increments the build number (CFBundleVersion) in the Xcode project
- Useful before creating new builds for TestFlight/App Store

**Usage:**
```bash
cd ios
bundle exec fastlane ios increment_build
```

**When to use:**
- Before creating a new build for TestFlight
- Before App Store submission
- To ensure unique build numbers for each release

---

### `ios clean`

**Purpose:** Clean all iOS build artifacts and dependencies.

**What it does:**
- Cleans Flutter build cache
- Removes CocoaPods dependencies (Pods directory)
- Attempts to reinstall CocoaPods (if possible)
- Prepares for a fresh build

**Usage:**
```bash
cd ios
bundle exec fastlane ios clean
```

**When to use:**
- Resolving build issues
- Cleaning up disk space
- Starting fresh after dependency changes
- Troubleshooting CocoaPods issues

---

## 🤖 Android Lanes

### `android build_debug`

**Purpose:** Build the Android app in debug mode for development and testing.

**What it does:**
- Fetches Flutter dependencies
- Builds Android APK in debug mode
- Creates an unsigned debug APK

**Usage:**
```bash
cd ios
bundle exec fastlane android build_debug
```

**Output Location:**
```
build/app/outputs/flutter-apk/app-debug.apk
```

**When to use:**
- Local development and testing
- Quick debug builds
- Testing on Android devices/emulators

---

### `android build_release_apk`

**Purpose:** Build a signed release APK for Android distribution.

**What it does:**
- Fetches Flutter dependencies
- Builds Android app in release mode
- Creates a signed release APK file

**Usage:**
```bash
cd ios
bundle exec fastlane android build_release_apk
```

**Output Location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**When to use:**
- Creating APK for direct distribution
- Side-loading on Android devices
- Testing release builds locally

---

### `android build_release_bundle`

**Purpose:** Build an Android App Bundle (AAB) for Google Play Store submission.

**What it does:**
- Fetches Flutter dependencies
- Builds Android app in release mode
- Creates an Android App Bundle (.aab file)

**Usage:**
```bash
cd ios
bundle exec fastlane android build_release_bundle
```

**Output Location:**
```
build/app/outputs/bundle/release/app-release.aab
```

**When to use:**
- Preparing for Google Play Store submission
- Creating optimized bundles for Play Store
- Production releases

**Note:** AAB files are required for Google Play Store submissions (APK is for direct distribution only).

---

### `android clean`

**Purpose:** Clean all Android build artifacts.

**What it does:**
- Cleans Flutter build cache
- Runs Gradle clean command
- Removes Android build artifacts

**Usage:**
```bash
cd ios
bundle exec fastlane android clean
```

**When to use:**
- Resolving Android build issues
- Cleaning up disk space
- Starting fresh after dependency changes

---

## 🔧 Common Lanes

### `get_dependencies`

**Purpose:** Fetch Flutter package dependencies.

**What it does:**
- Runs `flutter pub get` to download and resolve all Flutter dependencies
- Updates package dependencies based on `pubspec.yaml`

**Usage:**
```bash
cd ios
bundle exec fastlane get_dependencies
```

**When to use:**
- After updating `pubspec.yaml`
- When dependencies are missing
- Before building the app
- After pulling new code with dependency changes

---

### `test`

**Purpose:** Run Flutter unit and widget tests.

**What it does:**
- Executes all Flutter tests in the project
- Runs tests defined in the `test/` directory

**Usage:**
```bash
cd ios
bundle exec fastlane test
```

**When to use:**
- Before committing code
- As part of CI/CD pipeline
- Verifying code changes
- Before creating releases

---

### `clean_all`

**Purpose:** Clean all build artifacts for both iOS and Android platforms.

**What it does:**
- Cleans Flutter build cache
- Removes iOS CocoaPods dependencies
- Cleans Android Gradle build artifacts
- Prepares for a completely fresh build

**Usage:**
```bash
cd ios
bundle exec fastlane clean_all
```

**When to use:**
- Major cleanup before important builds
- Resolving cross-platform build issues
- Freeing up disk space
- Starting completely fresh

---

## 📝 Quick Reference

### Common Workflows

**iOS Development Build:**
```bash
bundle exec fastlane ios build_debug
```

**iOS Release Build:**
```bash
bundle exec fastlane ios build_release
```

**Create IPA for Testing:**
```bash
bundle exec fastlane ios build_ipa
```

**Upload to TestFlight:**
```bash
bundle exec fastlane ios increment_build
bundle exec fastlane ios upload_testflight
```

**Android Release APK:**
```bash
bundle exec fastlane android build_release_apk
```

**Android Play Store Bundle:**
```bash
bundle exec fastlane android build_release_bundle
```

---

## 🔑 Important Notes

1. **All commands should be run from the `ios` directory:**
   ```bash
   cd ios
   bundle exec fastlane [lane_name]
   ```

2. **Code Signing:** iOS builds require proper code signing setup in Xcode. Make sure your certificates and provisioning profiles are configured.

3. **Build Numbers:** Always increment build numbers before TestFlight/App Store uploads:
   ```bash
   bundle exec fastlane ios increment_build
   ```

4. **TestFlight Authentication:** The `upload_testflight` lane requires App Store Connect authentication. You may need to set up API keys or authenticate with your Apple ID.

5. **Export Methods:** Different export methods require different certificates:
   - `development` - Development certificate
   - `ad-hoc` - Distribution certificate with ad-hoc provisioning profile
   - `app-store` - Distribution certificate with App Store provisioning profile
   - `enterprise` - Enterprise distribution certificate

---

## 📚 Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Flutter Build Documentation](https://docs.flutter.dev/deployment)
- [App Store Connect](https://appstoreconnect.apple.com/)

---

**Last Updated:** November 2025

