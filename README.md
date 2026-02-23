# Sample Flutter App

A production-ready Flutter starter template with enterprise-grade features and best practices.

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

Use `Bloc` or `Cubit` in the `flutter_bloc` package to manage state. Define the logics as specific as possible, e.g. Create a `LoginBloc` and a `ForgotPasswordBloc`, avoid creating a `UserBloc` for all authenication related logic.
