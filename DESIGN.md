# Sample App — Starter Structure

This project is a **skeleton starter** aligned with the Depozio app structure. Use it as a template for new projects (clone and rename).

## Design focus

- **Light mode first** — All UI (screens, components, colors, contrast) is designed and tuned for light mode. Dark mode is supported via theme switching but is secondary; polish dark-mode specifics later if needed.

## Structure (Depozio-aligned)

- **Router** (`lib/router/`)
  - `app_page.dart` — Enum of all pages with `name`, `path`, `icon` (IconData), and `navBarMemberIndex` (99 = standalone, not in bottom nav).
  - `app_router.dart` — Splash at `/splash`, redirect `/` → `/splash`, standalone routes (e.g. login), and `StatefulShellRoute.indexedStack` with branches built from `AppPage` (navBarMemberIndex ≠ 99).

- **Navigation**
  - `ScaffoldWithNavBar` — Uses theme `colorScheme.surface`, bottom offset -25, `SafeArea(top: false)`.
  - `NavBarMembersWidget` — Bottom bar driven by `AppPage` (sorted by `navBarMemberIndex`).

- **Splash** — `SplashScreen` shows briefly then navigates to `/home`.

- **main.dart** — `try/catch` around `Environment.load()`, `FlutterError.onError`, `runZonedGuarded` for error handling.

## Skeleton scope

- No real features; placeholder pages only (Home, Explore, Activity, Settings, Login).
- Login flow is minimal (BLoC + go_router); Settings has Sign In / Sign Out only.

## Extending

- Add new nav tabs: add an enum value to `AppPage` with the desired `navBarMemberIndex`, then add the page to `_appPages` and a branch in the router.
- Add standalone routes: add to `AppPage` with `navBarMemberIndex: 99` and to `_standaloneAppPages`.

Design practices and patterns follow the Depozio codebase.
