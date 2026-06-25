# Triftly

**Your Global Travel OS — Explore, Plan, Spend.**

A modern, minimal Flutter mobile app redesigned by WY Limited. One app for the entire travel lifecycle: discover destinations, plan your itinerary, and split expenses — no switch between apps.

---

## Core Business

Triftly is built around **3 pillars** that cover every step of a trip:

- **Explore** — Browse curated travel content and popular destinations. Get inspired before you book.
- **Plan** — Build day-by-day itineraries, add spots (pois, restaurants, hikes), and see everything on a map.
- **Spend** — Log expenses on the go, split bills with travel buddies, and settle up fairly.

We target travelers who care about design and simplicity — not a bloated trip planner, just enough tooling to go.

---

## Tech Stack

- **Framework:** Flutter 3.6+ (iOS 14+ / Android min SDK 21+)
- **Language:** Dart 3+
- **State:** flutter_bloc (Bloc, stateless screens)
- **Navigation:** go_router + StatefulShellRoute
- **Database:** Supabase (PostgreSQL + Auth)
- **Offline:** Hive + Drift
- **Money:** decimal package (100% accurate — never double/num)
- **Maps:** google_maps_flutter
- **Font:** Satoshi (modern, clean, minimal)

---

## Architecture

```
lib/
 ├── app.dart                      # App entry + MaterialApp theme
 ├── main.dart                     # main() — init Supabase + Hive + runApp
 └── core/
 │   ├── constants/                # AppColors, AppPage enum, AppConfig
 │   ├── environment/              # Dev / stag / prod env flags
 │   ├── models/                   # Equatable models (Trip, Day, Spot, Expense, …)
 │   ├── navigation/               # go_router setup + floating bottom nav shell
 │   ├── services/                 # SplitCalculator (equal / percent / amount / share)
 │   └── theme/                    # AppColors + AppTheme (Material 3, light)
 └── features/
     ├── 1_explore/                # Explore page (curated destinations)
     ├── 5_trip_list/             # Trip list + create trip bottom sheet
     │   └── bloc/                # TripListBloc / state / event
     ├── 6_trip_detail/           # Trip detail — Plan / Spend / Map tabs
     │   ├── bloc/                # TripDetailBloc / state / event
     │   ├── presentation/
     │   │   ├── pages/           # TripDetailPage (3-tab scaffold)
     │   │   ├── widgets/         # PlanTab, SpendTab, MapTab
     │   │   └── bottom_sheets/   # AddSpotBottomSheet
     │   └── data/                # (Supabase repos — TODO)
     └── 4_profile/               # Profile page (settings placeholder)
```

---

## Package Name

- **Flutter package:** `triftly`
- **iOS bundle ID:** `com.triftly`
- **Android applicationId:** `com.triftly`

---

## Getting Started

```bash
flutter pub get
cp env/.env.local.example env/.env.local   # fill from GitHub secrets
./tool/dart_defines.sh dev flutter run
```

Environments: `dev`, `stag`, `prod` (toggle via `--dart-define=ENV=<env>`). See `env/README.md`.

---

## Project Conventions

- **No SnackBar.** Feedback via BLoC-driven UI updates, inline validation, dialogs, or in-sheet messaging.
- **Bloc over Cubit.** Screens are `StatelessWidget`; business logic lives in blocs.
- **Decimal for money.** Never use `double` or `num` for currency. `package:decimal` only.
- **Soft deletes.** `is_active` boolean — never hard delete rows.
- **Minimal design.** Clean, modern, light mode first. Things 3 / Linear / Arc-inspired.
- **No full-page tables.** Action panels via bottom sheet; cards have left border = category color.

---

## CI / CD

- **iOS deployment:** Fastlane → TestFlight (`bundle exec fastlane ios upload_testflight`)
- **Android deployment:** TBD (Play Console)
- GitHub Actions: `.github/workflows/deploy-testflight.yml`, `.github/workflows/migrate-supabase.yml`
- **Secrets:** single source of truth in GitHub — see `env/README.md`
- Never put credentials in committed `env/.env.*` files or `ios/fastlane/.env.default`

---

## Status

Phase 1 MVP complete — scaffold + core pages + models + navigation + build verified.
