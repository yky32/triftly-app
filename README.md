# Triftly

**Drift Through Your Day – Plans, Maps, Budget**

A production-ready Flutter app with enterprise-grade features and best practices.

## 🚀 Core Features

- Theming scaffolding with [`ThemeExtension`](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
- Routing scaffolding with [`go_router`](https://pub.dev/packages/go_router)
- Localization scaffolding with [`flutter_localizations`](https://pub.dev/packages/flutter_localizations)
- State management with [`flutter_bloc`](https://pub.dev/packages/flutter_bloc)
- Forms with [`flutter_form_builder`](https://pub.dev/packages/flutter_form_builder) and [`form_builder_validators`](https://pub.dev/packages/form_builder_validators)
- Toggle environment variables with a single argument (`--dart-define=ENV=dev`, `--dart-define=ENV=stag`, `--dart-define=ENV=prod`)

## Getting Started

Clone the repository and use it as a base for development.

Use the following command to install dependencies:

```bash
flutter pub get
```

To run the app, run the following command:

```bash
flutter run
```

## Environment Variables

Go to the `env` folder and edit the files inside, then run the app with the `--dart-define` argument.

```bash
flutter run --dart-define=ENV=dev
```

Or replace `dev` with `stag` or `prod` to toggle between staging and production environments.

## Theming

Define all styles in the `theme/theme.dart` file. Do not define styles inside components.
If you want to define some variables that are not available in the `ThemeData` class, you can define them in the `theme/theme_extension.dart` file.

## Routing

Define all routes in the `enum/route.dart` file, then update the `route/router_config.dart` file.

## Localization

To create a new locale, create a new file inside the `l10n` folder and run the app, the localization will be generated automatically.

## State Management

Use **Bloc only** (no Cubit). All state is managed via [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) with events and states. Define blocs as specific as possible—e.g. `LoginBloc`, `ThemeBloc`, `ForgotPasswordBloc`—and avoid a single catch‑all bloc (e.g. no `UserBloc` for all auth logic).

## Bottom Sheets

Bottom sheets in this app follow a consistent set of behaviors and design rules:

- **Drag handle** – Every bottom sheet shows a drag handle (pill) at the top to signal that it can be dragged to dismiss. Use `BottomSheetDragHandle` from `app_bottom_sheet.dart`.
- **Tap-to-unfocus** – Tapping outside any focused text field must unfocus it and dismiss the keyboard so the sheet content is not blocked. Wrap sheet content in `TapToUnfocus` from `app_bottom_sheet.dart`.
- **Borderless inputs** – Text fields inside bottom sheets use borderless styling (no visible border; optional subtle underline). Do not use outlined or filled bordered fields in sheets.
- **Keyboard insets** – Sheet layout must account for the keyboard (e.g. `MediaQuery.viewInsetsOf(context).bottom`) so content remains visible and scrollable when the keyboard is open.
- **Present via `showAppModalBottomSheet`** – Use the shared helper in `app_bottom_sheet.dart` so sheets use the root navigator and consistent styling.

Do not use `SnackBar` / `showSnackBar` in this app; use other patterns for feedback (e.g. inline validation, dialogs, or in-sheet messaging).
