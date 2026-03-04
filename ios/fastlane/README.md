fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### get_dependencies

```sh
[bundle exec] fastlane get_dependencies
```

Get Flutter dependencies

### test

```sh
[bundle exec] fastlane test
```

Run Flutter tests

### clean_all

```sh
[bundle exec] fastlane clean_all
```

Clean all build artifacts

----


## iOS

### ios build_debug

```sh
[bundle exec] fastlane ios build_debug
```

Build iOS app for development (Debug)

### ios build_release

```sh
[bundle exec] fastlane ios build_release
```

Build iOS app for release

### ios build_ipa

```sh
[bundle exec] fastlane ios build_ipa
```

Build iOS app and create IPA (requires code signing)

Options: export_method - 'development', 'ad-hoc', 'app-store', or 'enterprise' (default: 'development')

         env - environment to use: 'dev', 'stag', or 'prod' (default: 'prod' for app-store, 'dev' for others)

### ios upload_testflight

```sh
[bundle exec] fastlane ios upload_testflight
```

Build IPA and upload to TestFlight

Options: skip_build - set to true to skip building and use existing IPA (default: false)

         env - environment to use: 'dev', 'stag', or 'prod' (default: 'prod')

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

Create app in App Store Connect

This will register your app in App Store Connect if it doesn't exist

### ios setup_appstore_signing

```sh
[bundle exec] fastlane ios setup_appstore_signing
```

Setup App Store distribution certificates and provisioning profiles

This will download/create Distribution certificate and App Store provisioning profile

### ios increment_build

```sh
[bundle exec] fastlane ios increment_build
```

Increment build number

### ios clean

```sh
[bundle exec] fastlane ios clean
```

Clean iOS build artifacts

----


## Android

### android build_debug

```sh
[bundle exec] fastlane android build_debug
```

Build Android app for development (Debug)

### android build_release_apk

```sh
[bundle exec] fastlane android build_release_apk
```

Build Android app for release (APK)

### android build_release_bundle

```sh
[bundle exec] fastlane android build_release_bundle
```

Build Android app for release (App Bundle)

### android clean

```sh
[bundle exec] fastlane android clean
```

Clean Android build artifacts

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
